extends Node
class_name CombatManager_

# Player and enemy character references
var player: BaseChar = Player_AL
@export var enemy:  BaseChar

@onready var combat_screen = $".."

# Enemy AI controller
var enemy_ai: EnemyAI

var turn_log: String = ""  # Buffer for this turn's combat text
var is_first_turn := true

#tweens for transition effects
@onready var health_tween = create_tween()
@onready var fade_tween = create_tween()

# UI elements for displaying combat information
@export var combat_log: RichTextLabel

#player and opponent val tracker
@export var player_health_label: Label
@export var enemy_health_label: Label
@export var enemy_name_label: Label

# UI buttons for player actions
@export var attack_button: Button
@export var defend_button: Button
@export var dodge_button: Button

# Damage-related variables
var damage:  int = 0
var turndamage: int = 0
var pending_finisher: Dictionary = {}

var reaction_applied: bool = false


# Combat states
enum State { PLAYER_TURN, ENEMY_TURN, BATTLE_OVER }
var current_state: State = State. PLAYER_TURN
var current_action: String = ""


# Technique preloads
var cleave_technique = load("res://logic/data/resources/Techniques/cleave.tres") as Technique_
var stab_technique = load("res://logic/data/resources/Techniques/quick_jab.tres") as Technique_

# Health display tweening
var displayed_player_val := 0.01
var displayed_enemy_val := 0.01

# Battle events
var battle_events: Array = []
var event_triggered:  bool = false

const ACTION_COSTS := {
	"light": 2,
	"heavy": 4,
	"finisher": 4,
	"defend": 1,
	"dodge": 2,
	"use_skill": 2,
	"observe": 1
}


func reset_combat_states(character: BaseChar):
	character.is_defending = false
	character.is_dodging = false
	character.reaction_applied = false
	decay_momentum(character)


func calculate_finisher_damage(
	attacker: BaseChar,
	target: BaseChar
) -> int:
	# Base offensive power
	var attack_power: float = attacker.stats["strength"] * 4.0

	attack_power += attacker.get_weapon_power() * 3.0

	# Massive finisher multiplier
	var finisher_multiplier := randf_range(20.0, 50.0)

	var raw_damage: float = attack_power * finisher_multiplier

	# Clamp so it always kills, but never overflows absurdly
	var lethal_damage: int = max(target.current_hp, int(raw_damage))

	return lethal_damage


class CombatResolution:
	# Participants
	var actor: BaseChar
	var target: BaseChar
	
	# Intent
	var action_id: String
	var technique: Technique_ = null
	var stance: String
	
	# Outcome flags (explicit, never inferred)
	var hit: bool = false
	var dodged: bool = false
	var blocked: bool = false
	
	# Damage & attrition
	var damage_hp: int = 0
	var damage_stamina: int = 0
	
	# Armor
	var armor_hit: String = ""
	var armor_broken: bool = false
	
	# Momentum
	var momentum_delta: int = 0
	var momentum_state_before: String
	var momentum_state_after: String
	
	# Escalation
	var opportunity_created: bool = false
	var finisher_created: bool = false
	
	# Reaction chaining
	var triggered_reaction: CombatResolution = null



### READY FUNCTION ###
func _ready():
	# 1) Accept player from CombatData if present
	if CombatData.player != null:
		player = CombatData.player

	# 2) Prefer an enemy_instance from CombatData
	if CombatData.enemy_instance != null:
		# remove default if present in this scene
		if enemy != null and enemy.get_parent() == self:
			enemy.queue_free()
		enemy = CombatData.enemy_instance
		# Ensure enemy is a child so its _ready runs
		if enemy.get_parent() == null:
			add_child(enemy)
		# Wait a frame for enemy._ready / tree_entered
		await get_tree().process_frame

	# 3) Otherwise if an enemy_id was provided, instantiate from EnemyCatalog
	elif CombatData.enemy_id != "":
		var id = CombatData.enemy_id
		if EnemyCatalog.enemy_templates.has(id):
			var scene = EnemyCatalog.enemy_templates[id]
			var new_enemy = scene.instantiate() as BaseChar
			# remove default if present
			if enemy != null and enemy.get_parent() == self:
				enemy.queue_free()
			add_child(new_enemy)
			enemy = new_enemy
			# Wait one frame for new_enemy._ready
			await get_tree().process_frame
			# apply overrides later (next step)
		else:
			push_warning("EnemyCatalog has no template for id '%s' — using default enemy." % id)

	# 4) If no CombatData provided and no exported enemy set, error
	if enemy == null:
		push_error("CombatManager: no enemy available. Assign a default in the editor or supply CombatData.")
		return

	# 5) Apply overrides from CombatData.enemy_config (if any)
	if CombatData.enemy_config and CombatData.enemy_config.size() > 0:
		_apply_enemy_overrides(enemy, CombatData.enemy_config)

	# 6) Set battle events
	battle_events = CombatData.battle_events.duplicate()

	# 7) Setup AI and UI
	_setup_ai()
	_initialize_ui()
	
	#add equipment 
	_setup_equipment()

	# 8) Clear CombatData to avoid stale references
	CombatData.clear()


func _load_procedural_enemy() -> void:
	"""Load enemy from EnemyCatalog based on narrative data."""
	
	var config = CombatData.enemy_config
	var enemy_id = config.get("enemy_id", "")
	
	if enemy_id == "" or not EnemyCatalog.enemy_templates.has(enemy_id):
		push_warning("Invalid enemy_id '%s', using default enemy." % enemy_id)
		return  # Fall back to default
	
	# Get template and instantiate
	var enemy_scene = EnemyCatalog.enemy_templates[enemy_id]
	var new_enemy = enemy_scene.instantiate() as BaseChar
	
	# Remove old default enemy from scene
	if enemy != null and enemy.get_parent() == self:
		enemy.queue_free()
	
	# Add new enemy to scene tree
	add_child(new_enemy)
	enemy = new_enemy
	
	# Apply overrides from narrative
	_apply_enemy_overrides(enemy, config)
	
	print("Procedural enemy loaded: %s" % enemy.display_name)


func _apply_enemy_overrides(target_enemy: BaseChar, config: Dictionary) -> void:
	if config.has("override_display_name") and config["override_display_name"] != null:
		target_enemy.display_name = config["override_display_name"]
	if config.has("override_hp") and config["override_hp"] != null:
		enemy.max_hp = int(config["override_hp"])
		enemy.current_hp = enemy.max_hp
	if config.has("override_stats"):
		for k in config["override_stats"]:
			enemy.stats[k] = config["override_stats"][k]
	if config.has("override_weapon") and config["override_weapon"] != null:
		var w = load(config["override_weapon"])
		if w:
			enemy.equip_weapon(w, "main_hand")
	if config.has("override_armor") and config["override_armor"] != null:
		var a = load(config["override_armor"])
		if a:
			enemy.equip_armor("chest", a)
	if config.has("override_techniques"):
		enemy.techniques.clear()
		for tpath in config["override_techniques"]:
			var tres = load(tpath)
			if tres:
				enemy.techniques.append(tres)

func _setup_equipment() -> void:
	"""Automatically equip player and enemy based on their inventories, skills, and techniques."""

	print("=== Setting up PLAYER equipment ===")

	# --- PLAYER SETUP ---
	# Equip all armor
	for slot_name in player.armor_slots.keys():
		var armor_piece = player.armor_data[slot_name]
		if armor_piece and armor_piece is ArmorResource:
			print("Equipping PLAYER armor in slot:", slot_name, "->", armor_piece.name)
			player.equip_armor(slot_name, armor_piece)
		else:
			print("No valid armor found in PLAYER slot:", slot_name)

	# Equip all weapons
	for slot_name in player.equipment.keys():
		var weapon = player.equipment[slot_name]
		if weapon and weapon is WeaponResource:
			print("Equipping PLAYER weapon in slot:", slot_name, "->", weapon.name)
			player.equip_weapon(weapon, slot_name)
		else:
			print("No valid weapon found in PLAYER slot:", slot_name)

	# Add all skills
	#for skill in player.skills:
	#	if skill is SkillResource:
	#		print("Adding PLAYER skill:", skill.name)
	#		player.add_skill(skill)
	#	else:
	#		print("Invalid skill found in PLAYER skills array")

	# Add all techniques
	var names = []
	for technique in player.techniques:
		if technique != null:
			names.append(technique.name)
	print("Player Techniques:", names)


	print("=== Player setup complete ===\n")

	# --- ENEMY SETUP ---
	print("=== Setting up ENEMY equipment ===")

	# Equip only if empty (respect procedural setups)
	if enemy.armor_slots.is_empty():
		print("Enemy armor slots empty. Equipping armor...")
		for slot_name in enemy.armor_slots.keys():
			var armor_piece = enemy.armor_slots[slot_name]
			if armor_piece and armor_piece is ArmorResource:
				print("Equipping ENEMY armor in slot:", slot_name, "->", armor_piece.name)
				enemy.equip_armor(slot_name, armor_piece)
			else:
				print("No valid armor found in ENEMY slot:", slot_name)

		for slot_name in enemy.equipment.keys():
			var weapon = enemy.equipment[slot_name]
			if weapon and weapon is WeaponResource:
				print("Equipping ENEMY weapon in slot:", slot_name, "->", weapon.name)
				enemy.equip_weapon(weapon, slot_name)
			else:
				print("No valid weapon found in ENEMY slot:", slot_name)
	else:
		print("Enemy already has armor. Skipping armor equip.")

	# Add all enemy skills
	for skill in enemy.skills:
		if skill is SkillResource:
			print("Adding ENEMY skill:", skill.name)
			enemy.add_skill(skill)
		else:
			print("Invalid skill found in ENEMY skills array")

	# Add all enemy techniques
	for technique in enemy.techniques:
		print("Adding ENEMY technique:", technique.name)
		enemy.add_technique(technique)

	print("=== Enemy setup complete ===\n")
	print("Final PLAYER and ENEMY objects:", player, enemy)



func _setup_ai() -> void:
	"""Initialize enemy AI controller."""
	
	enemy_ai = EnemyAI.new()
	enemy_ai.enemy = enemy
	enemy_ai. player = player
	print("AI initialized for %s" % enemy.display_name)


func _initialize_ui() -> void:
	"""Set up UI and display starting battle log."""
	
	combat_screen.bind_actor(player)
	combat_log.bbcode_enabled = true
	combat_log.clear()
	
	add_to_turn_log("Battle started!  %s vs %s \n\n" % [player.display_name, enemy.display_name])
	finalize_turn_log()
	
	# Fade-in effect
	combat_log.modulate. a = 0.0
	fade_tween = create_tween()
	fade_tween.tween_property(combat_log, "modulate:a", 1.0, 1.0)
	
	update_health_labels()
	print("Combat UI initialized.")


func _process(_delta):
	# Safety checks
	if player == null or enemy == null: 
		return
	
	player_health_label.text = "Player Val: %d" % int(displayed_player_val)
	enemy_health_label.text = "Enemy Val: %d" % int(displayed_enemy_val)
	enemy_name_label.text = enemy.display_name
	player. update_val()
	enemy.update_val()


#----
 
func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	# Validation & AP
	if not has_enough_ap(actor, action):
		add_to_turn_log("%s is unable to act — insufficient AP." % actor.display_name)
		return
	consume_ap(actor, action)

	var res := CombatResolution.new()
	res.actor = actor
	res.target = target
	res.action_id = action
	res.stance = actor.current_stance

	var is_attack := true

	# ── DEFEND / DODGE ──
	if action == "defend":
		is_attack = false
		actor.is_defending = true
		res.hit = false
		add_to_turn_log(generate_attack_description(res))
		return

	elif action == "dodge":
		is_attack = false
		actor.is_dodging = true
		res.hit = false
		add_to_turn_log(generate_attack_description(res))
		return

	# ── SKILL ACTIONS ──
	if action == "use_skill":
		actor.use_selected_skill(target)
		return

	# ── ATTACK ACTIONS ──
	if is_attack:
		var chosen_technique = choose_technique(actor, target, action)
		res.technique = chosen_technique

		var dmg_result = damage_calc(actor, target, action, chosen_technique)
		res.hit = dmg_result.hit
		res.dodged = dmg_result.dodged
		res.blocked = dmg_result.blocked
		res.damage_hp = dmg_result.damage

		if res.damage_hp > 0:
			target.current_hp = clamp(target.current_hp - res.damage_hp, 0, target.max_hp)

	# ── MOMENTUM & ESCALATION ──
	var momentum_added = calculate_momentum(actor, target, res.technique)
	res.momentum_state_before = target.get_momentum_state()
	if momentum_added != 0:
		target.momentum += momentum_added
		res.momentum_delta = momentum_added
	res.momentum_state_after = target.get_momentum_state()

	# Escalation
	if not target.finisher_active and target.momentum >= target.finisher_available:
		target.finisher_active = true
		res.finisher_created = true
	elif not target.opportunity_active and target.momentum >= target.opportunity_available:
		target.opportunity_active = true
		res.opportunity_created = true

	# Trigger reaction on target (once per turn)
	res.triggered_reaction = null
	if target.finisher_active:
		res.triggered_reaction = trigger_auto_counter("finisher", actor, target)
	elif target.opportunity_active:
		res.triggered_reaction = trigger_auto_counter("opportunity", actor, target)


	# Add main attack description
	add_to_turn_log(generate_attack_description(res))

	# Add reaction description if one exists
	if res.triggered_reaction != null:
		add_to_turn_log(generate_attack_description(res.triggered_reaction))

	# Cleanup & UI
	process_stamina_endurance(actor, action)
	update_health_labels()
	check_battle_end()



#----




# action point managers
func has_enough_ap(actor: BaseChar, action: String) -> bool:
	if not ACTION_COSTS.has(action):
		return true # free / narrative actions
	return actor.action_points >= ACTION_COSTS[action]

func consume_ap(actor: BaseChar, action: String) -> void:
	if ACTION_COSTS.has(action):
		actor.action_points -= ACTION_COSTS[action]
		actor.action_points = max(actor.action_points, 0)
		print("\n\n",ACTION_COSTS[action], " AP is how much ap ", actor.display_name, " Used this turn.")
		print(actor.display_name, " Has ", actor.action_points, " Left.")


func regenerate_action_points(actor: BaseChar) -> int:
	var regen := 2  # hard minimum
	var roll := randf()

	# Base probabilities
	var chance_three := 0.25
	var chance_three_four := 0.10

	if actor.val >= 7:
		# Full probabilities
		pass

	elif actor.val >= 2:
		# Scale linearly from VAL 6 -> 2
		# VAL 6 = near baseline
		# VAL 2 = minimum values

		var t := float(7 - actor.val) / 5.0
		# t = 0 at VAL 7
		# t = 1 at VAL 2

		chance_three = lerp(0.25, 0.08, t)
		chance_three_four = lerp(0.10, 0.02, t)

	else:
		# VAL == 1 desperation rebound
		chance_three = 0.20
		chance_three_four = 0.0

	# Resolve regen
	if roll < chance_three_four:
		regen = randi_range(3, 4)
	elif roll < chance_three_four + chance_three:
		regen = 3
	else:
		regen = 2

	# Apply
	actor.action_points += regen

	print(
		"VAL:", actor.val,
		"| Regen:", regen,
		"| Chances — 3:", snapped(chance_three, 0.001),
		" 3–4:", snapped(chance_three_four, 0.001)
	)

	return regen



func trigger_auto_counter(counter_type: String, counterer: BaseChar, victim: BaseChar) -> CombatResolution:
	# Skip if reaction already applied this turn for this counter
	if counterer.reaction_applied:
		return null
	counterer.reaction_applied = true

	var res := CombatResolution.new()
	res.actor = counterer
	res.target = victim
	res.action_id = counter_type
	res.stance = counterer.current_stance

	var damage_result := {}

	match counter_type:
		"finisher":
			damage_result = {
				"hit": true,
				"dodged": false,
				"blocked": false,
				"damage": calculate_finisher_damage(counterer, victim)
			}
			res.finisher_created = false

		"opportunity":
			var chosen_technique = choose_technique(counterer, victim, "opportunity")
			res.technique = chosen_technique

			damage_result = damage_calc(counterer, victim, "opportunity", chosen_technique)

		_:
			return null

	# Apply results
	res.hit = damage_result.hit
	res.dodged = damage_result.dodged
	res.blocked = damage_result.blocked
	res.damage_hp = damage_result.damage

	if res.damage_hp > 0:
		victim.current_hp = clamp(victim.current_hp - res.damage_hp, 0, victim.max_hp)

	# Momentum from reaction
	var momentum_delta = calculate_momentum(counterer, victim, res.technique)
	momentum_delta = int(momentum_delta * 0.5)
	res.momentum_state_before = victim.get_momentum_state()
	if momentum_delta != 0:
		victim.momentum += momentum_delta
		res.momentum_delta = momentum_delta
	res.momentum_state_after = victim.get_momentum_state()

	# Reset opportunity/finisher on victim if needed
	if counter_type == "finisher":
		victim.finisher_active = false
		victim.opportunity_active = false
		victim.momentum = 0
	elif counter_type == "opportunity":
		victim.opportunity_active = false
		victim.momentum = 10
	return res



func resolve_pending_finisher() -> CombatResolution:
	if pending_finisher.is_empty():
		return null

	var attacker: BaseChar = pending_finisher.attacker
	var target: BaseChar = pending_finisher.target
	var technique: Technique_ = pending_finisher.technique

	var res := CombatResolution.new()
	res.actor = attacker
	res.target = target
	res.action_id = "finisher"
	res.technique = technique
	res.stance = attacker.current_stance

	# ─────────────────────────────
	# FINISHERS ARE ABSOLUTE
	# ─────────────────────────────
	res.hit = true
	res.dodged = false
	res.blocked = false

	res.damage_hp = calculate_finisher_damage(attacker, target)
	res.damage_stamina = 0

	# ─────────────────────────────
	# APPLY DAMAGE
	# ─────────────────────────────
	target.current_hp = clamp(
		target.current_hp - res.damage_hp,
		0,
		target.max_hp
	)

	# ─────────────────────────────
	# MOMENTUM STATE
	# ─────────────────────────────
	res.momentum_state_before = target.get_momentum_state()
	res.momentum_delta = -target.momentum
	target.momentum = 0
	res.momentum_state_after = target.get_momentum_state()

	# ─────────────────────────────
	# CLEANUP FLAGS
	# ─────────────────────────────
	attacker.finisher_used_this_turn = true
	target.finisher_active = false
	target.opportunity_active = false

	if technique:
		technique.trigger_cooldown()

	pending_finisher.clear()

	return res



func choose_technique(actor: BaseChar, target: BaseChar, attack_type: String) -> Technique_:
	for techniques in actor.techniques:
		if techniques.attack_type != attack_type:
			continue
		if techniques.stance_required != "" and techniques.stance_required != actor.current_stance:
			continue
		if techniques.requires_momentum > 0 and actor.momentum < techniques.requires_momentum:
			continue
		if techniques.trigger_condition != null and techniques.trigger_condition. is_valid():
			if not techniques.trigger_condition.call(actor, target):
				continue
				
		print(techniques, "Is found")
		return techniques
		

	print("No valid technique found for %s (attack type: %s). Techniques checked: %d"
		% [actor.display_name, attack_type, actor.techniques.size()])
	return null


func decay_momentum(actor: BaseChar):
	if actor.momentum <= 0:
		return

	var health_ratio = float(actor.current_hp) / actor.max_hp
	var stamina_ratio = float(actor. stamina) / actor.max_stamina

	var condition = (stamina_ratio * 0.7) + (health_ratio * 0.3)
	var max_decay = lerp(2, 5, condition)
	var decay_amount = randi_range(2, int(max_decay))

	print("\n\n--- Momentum Decay Report ---")
	print("Actor:", actor.name)
	print("Health:", actor.current_hp, "/", actor.max_hp, "(", round(health_ratio * 100.0), "% )")
	print("Stamina:", actor.stamina, "/", actor.max_stamina, "(", round(stamina_ratio * 100.0), "% )")
	print("Weighted Condition Score:", round(condition * 100.0), "%")
	print("Calculated Decay Range:  2 to ", int(max_decay))
	print("Final Momentum Lost:", decay_amount)
	print("Reason: Condition-based momentum decay (stamina-weighted)")
	print("-----------------------------\n\n")

	adjust_momentum(actor, -decay_amount, "condition-based momentum decay")

func calculate_momentum(actor: BaseChar, target: BaseChar, technique: Technique_) -> int:
	var momentum_gain: int = 0

	# 10% chance no momentum is applied
	if randi() % 100 < 10:
		return 0

	# Determine base momentum range
	var min_mom: int
	var max_mom: int

	if technique != null:
		match technique.attack_type:
			"light":
				min_mom = 4
				max_mom = 6
			"heavy":
				min_mom = 5
				max_mom = 8
			"special":
				min_mom = 10
				max_mom = 10
			"finisher":
				min_mom = 10
				max_mom = 10
			_:
				min_mom = 5
				max_mom = 10
	else:
		# No technique, standard attack
		min_mom = 2
		max_mom = 8

	# Random momentum within range
	momentum_gain = randi() % (max_mom - min_mom + 1) + min_mom

	# Add technique bonus if any

	# Optional: scale slightly with actor stats (strength, focus)


	return momentum_gain



func process_stamina_endurance(actor: BaseChar, action: String) -> void:
	var is_attacking = action == "light" or action == "heavy"

	if is_attacking:
		var weapon_power = actor.get_weapon_power()
		var strength = actor.stats.get("strength", 0)
		var stamina_cost = int(weapon_power + 0.2 + strength )
		actor.stamina -= stamina_cost
		print("\n\n🗡️", actor.name, " performed ", action, " Action - Stamina cost: ", stamina_cost)
	else:
		actor.stamina += 5
		print("💨", actor.name, " rested - Stamina recovered:  +5")

	actor.stamina = clamp(actor.stamina, 0, actor.max_stamina)
	print("📊", actor.name, " Stamina after update: ", actor.stamina, "/", actor.max_stamina)

	var stamina_ratio = float(actor. stamina) / float(actor.max_stamina)

	if stamina_ratio < 0.5:
		var loss = 0.005 * actor.max_endurance
		actor.endurance -= loss
		print("⚠️", actor.name, " low stamina - Endurance decreased by ", loss)
	elif stamina_ratio > 0.75:
		var gain = 0.003 * actor.max_endurance
		actor.endurance += gain
		print("💪", actor.name, " high stamina - Endurance increased by ", gain)
	else:
		print("⏸️", actor.name, " mid-range stamina - Endurance unchanged ")

	actor.endurance = clamp(actor.endurance, 0.0, actor.max_endurance)
	print("📈", actor.name, " Endurance after update: ", actor.endurance, "/", actor.max_endurance)



##LOGGING
func add_to_turn_log(text: String):
	"""
	Adds text to the turn log buffer. Logs are collected and displayed at the end of the turn.
	"""
	turn_log += text + " "


func finalize_turn_log():
	if turn_log.strip_edges() != "":
		# Append collected log to combat log, separated by a blank line
		combat_log.append_text("%s\n\n" % turn_log.strip_edges())
		turn_log = ""

	update_health_labels()

	# Reset states for next turn
	player.is_dodging = false
	player.is_defending = false
	enemy.is_dodging = false
	enemy.is_defending = false

func damage_calc(
	actor: BaseChar,
	target: BaseChar,
	attack_type: String,
	technique: Technique_ = null
) -> Dictionary:
	
	var result := {
		"hit": true,
		"dodged": false,
		"blocked": false,
		"damage": 0
	}

	var attack_power = actor.stats["strength"] * 2.7 + actor.get_weapon_power()
	var multiplier = get_final_multiplier(actor, target, attack_type, technique)
	var base_damage = attack_power * multiplier


	if target.is_defending:
		result.blocked = true
		result.hit = false
		base_damage *= randf_range(0.4, 0.7)

	elif target.is_dodging:
		if randf() < 0.6:
			result.dodged = true
			result.hit = false
			base_damage = 0
			
	base_damage -= apply_armor_reduction(target, attack_power)

	var defense_modifier = target.stats["toughness"] * 1.64
	var final_damage = max(int(base_damage - defense_modifier), 0)

	result.damage = final_damage
	return result


	
	

func apply_armor_reduction(target: BaseChar, attack_power: float) -> float:
	if target.armor_slots == null:
		return 0.0

	var total_reduction := 0.0
	var broken_armor_slots := []

	# Multiplier for defending stance
	var defend_multiplier: float = 1.0
	if target.is_defending:
		defend_multiplier = randf_range(1.2, 2.8)

	for armor_piece in target.armor_slots.values():
		if armor_piece is ArmorResource:
			if armor_piece.broken:
				continue

			# Scale reduction by durability and defending stance
			var durability_factor = float(armor_piece.durability) / armor_piece.max_durability
			var scaled_reduction = armor_piece.damage_reduction * durability_factor * defend_multiplier
			var reduced_amount = attack_power * scaled_reduction

			total_reduction += reduced_amount

			# Chance to break low-durability armor
			if durability_factor < 0.303:
				if randi() % 100 < 50:
					add_to_turn_log("%s's %s Armor breaks due to low durability!" % [target.display_name, armor_piece.name])
					armor_piece.broken = true
					broken_armor_slots.append(armor_piece.slot_name)

	# Remove broken armor from target slots
	for slot_name in broken_armor_slots:
		target.armor_slots.erase(slot_name)

	return total_reduction



func update_armor_durability(target:  BaseChar, attack_power: float) -> void:
	if target. armor_slots == null:
		return

	for slot in target.armor_slots.values():
		if slot is ArmorResource:
			var durability_loss = int(attack_power * 0.1)
			slot.durability = max(slot.durability - durability_loss, 0)

			if slot.durability < (slot.max_durability * 0.3):
				if randf() < 0.25:
					add_to_turn_log("%s's %s Armor breaks under the stress unexpectedly!" % [target.display_name, slot.slot_name])
					slot.broken = true
					slot.durability = 0


func adjust_momentum(actor: BaseChar, amount: int, reason: String = ""):
	actor.momentum = clamp(actor.momentum + amount, 0, actor.max_momentum)
	print("Momentum adjusted for %s by %d (%s). Current momentum: %d" %
		[actor.display_name, amount, reason, actor.momentum])

func get_final_multiplier(actor: BaseChar, target: BaseChar, attack_type: String, technique: Technique_ = null) -> float:
	var multiplier: float = 1.0

	# Apply technique-specific multiplier
	if technique != null:
		multiplier *= technique.power_multiplier(actor)
		print("non technique multiplyer")
	# Apply attack type multiplier
	match attack_type:
		"light":
			multiplier *= 1.0
		"heavy":
			multiplier *= 1.25
		"special":
			multiplier *= 1.4
		"finisher":
			multiplier *= 1.7

	# Apply low HP bonus multiplicatively

	return multiplier



@warning_ignore("shadowed_variable")
func generate_attack_description(res: CombatResolution) -> String:
	var lines := []

	# --- 1. Opening Intent ---
	if res.technique:
		var open_flavor = [
			"%s commits to %s.",
			"%s delivers %s.",
			"%s attacks with %s!",
			"%s strikes cleanly with %s.",
			"%s strikes with %s.",
			"%s executes %s.",
			"%s swings into %s.",
			"%s strikes  using %s.",
			"%s unleashes %s!",
			"%s uses %s!"
		]
		lines.append(open_flavor[randi() % open_flavor.size()] % [res.actor.display_name, res.technique.name])
	else:
		if res.actor.is_defending:
			var defend_flavor = [
				"%s assumes a defensive stance.",
				"%s braces for impact.",
				"%s steadies for the incoming strike.",
				"%s tenses, ready to deflect.",
				"%s shifts into a defensive posture.",
				"%s steadies their guard."
			]
			lines.append(defend_flavor[randi() % defend_flavor.size()] % res.actor.display_name)
		elif res.actor.is_dodging:
			var dodge_flavor = [
				"%s prepares to dodge.",
				"%s shifts weight, anticipating a strike.",
				"%s reads the enemy’s move carefully.",
				"%s moves lightly, avoiding harm."
			]
			lines.append(dodge_flavor[randi() % dodge_flavor.size()] % res.actor.display_name)
		else:
			var act_flavor = [
				"%s acts.",
				"%s begins his action.",
				"%s strikes decisively.",
				"%s seizes the moment.",
				"%s moves with intent.",
				"%s presses the attack."
			]
			lines.append(act_flavor[randi() % act_flavor.size()] % res.actor.display_name)

	# --- 2. Hit / Deflect / Block ---
	if res.dodged:
		var dodge_flavor = "%s evades the attack!" % res.target.display_name
		if res.target.momentum >= res.target.finisher_available * 0.7:
			var extra = [
				" Momentum keeps them on their toes!",
				"They twist away, momentum aiding their reflexes!",
				"Quick reflexes fueled by momentum!"
			]
			dodge_flavor += extra[randi() % extra.size()]
		lines.append(dodge_flavor)
	elif res.blocked:
		var block_flavor = "%s blocks the strike." % res.target.display_name
		if res.actor.val >= 7:
			var extra = [
				" %s’s precision barely scratches them." % res.actor.display_name,
				" %s’s focus fails to break their guard." % res.actor.display_name,
				" %s’s strike is blocked." % res.actor.display_name
			]
			block_flavor += extra[randi() % extra.size()]
		lines.append(block_flavor)
	elif res.hit:
		var hit_flavor = "The strike hits with %d damage!" % res.damage_hp
		if res.target.momentum >= res.target.finisher_available * 0.7:
			var extra = [
				" The attack rattles %s, leaving them exposed!" % res.target.display_name,
				" %s reels from the hit!" % res.target.display_name,
				" %s staggers, openings appear!" % res.target.display_name
			]
			hit_flavor += extra[randi() % extra.size()]
		if res.actor.val >= 7:
			var extra_val = [
				" With focus, %s maximizes the impact!" % res.actor.display_name,
				" %s strikes his opponent!" % res.actor.display_name,
				" A concentrated blow from %s lands perfectly!" % res.actor.display_name
			]
			hit_flavor += " " + extra_val[randi() % extra_val.size()]
		lines.append(hit_flavor)

	# --- 3. Armor Reaction ---
	if res.armor_hit != "":
		if res.armor_broken:
			var armor_break_flavor = [
				"%s’s %s armor shatters!" % [res.target.display_name, res.armor_hit],
				"A mighty blow breaks %s’s %s!" % [res.target.display_name, res.armor_hit],
				"%s is exposed as %s armor gives way!" % [res.target.display_name, res.armor_hit]
			]
			lines.append(armor_break_flavor[randi() % armor_break_flavor.size()])
		else:
			var armor_hit_flavor = [
				"The strike clangs against %s’s %s armor." % [res.target.display_name, res.armor_hit],
				"%s’s %s armor absorbs the impact." % [res.target.display_name, res.armor_hit],
				"A solid hit bounces off %s’s %s armor." % [res.target.display_name, res.armor_hit]
			]
			lines.append(armor_hit_flavor[randi() % armor_hit_flavor.size()])

	# --- 4. Escalation Priority ---
	if res.finisher_created:
		var finisher_flavor = [
			"%s is left completely exposed!" % res.target.display_name,
			"An opening appears! %s is vulnerable!" % res.target.display_name,
			"%s falters, inviting a decisive blow!" % res.target.display_name
		]
		lines.insert(0, finisher_flavor[randi() % finisher_flavor.size()])
	elif res.opportunity_created:
		var opp_flavor = [
			"%s falters, leaving an opening!" % res.target.display_name,
			"An opportunity arises! %s is off-guard!" % res.target.display_name,
			"%s’s misstep creates a follow-up chance!" % res.target.display_name
		]
		lines.insert(0, opp_flavor[randi() % opp_flavor.size()])

	return "  ".join(lines)





### HEALTH UI ###

func update_health_labels():
	if health_tween != null:
		health_tween.kill()
	
	health_tween = create_tween()
	health_tween.tween_property(self, "displayed_player_val", player. val, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	health_tween.tween_property(self, "displayed_enemy_val", enemy. val, 0.5).set_trans(Tween. TRANS_LINEAR).set_ease(Tween.EASE_OUT)


func set_displayed_player_val(val):
	displayed_player_val = val
	player_health_label.text = "Player Val: %d" % int(val)


func set_displayed_enemy_val(val):
	displayed_enemy_val = val
	enemy_health_label.text = "Enemy Val: %d" % int(val)


### END OF BATTLE ###
func check_battle_end():
	"""
	Checks if either the player or the enemy has been defeated.
	"""
	if player. current_hp <= 0:
		add_to_turn_log("\n\n%s has been defeated!  Game Over." % player.display_name)
		current_state = State.BATTLE_OVER
		TransitionManager.transition(2.2)
		await TransitionManager.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/game_screen.tscn")
	elif enemy.current_hp <= 0:
		add_to_turn_log("\n\n%s has been defeated! You Win!" % enemy.display_name)
		current_state = State.BATTLE_OVER
		var timer = get_tree().create_timer(2.0)
		TransitionManager.transition(3.5)
		await TransitionManager. on_transition_finished
		get_tree().change_scene_to_file("res://scenes/game_screen.tscn")


### TURN PROCESSING ###
func process_turn(action: String):
	if current_state == State.BATTLE_OVER:
		return

	if current_state == State.PLAYER_TURN:

		add_to_turn_log("  ")
		trigger_event()
		
		resolve_action(player, action, enemy)
		if current_state != State.BATTLE_OVER: 
			current_state = State.ENEMY_TURN
			enemy_turn()

		player. update_val()
		enemy.update_val()
		
		print(turn_log)
		var finisher_res := resolve_pending_finisher()
		if finisher_res:
			add_to_turn_log(generate_attack_description(finisher_res))

		finalize_turn_log()


		var player_regen = regenerate_action_points(player)
		var enemy_regen = regenerate_action_points(enemy)

		print("Player regenerated ", player_regen, " AP.")
		print("Enemy regenerated ", enemy_regen, " AP.")
		print(enemy.momentum, " Is Enemy momentum")
		print(player.momentum, " Is player momentum")
				
		reset_combat_states(player)
		reset_combat_states(enemy)

func enemy_turn():
	"""
	Handles the enemy's turn by allowing the AI to choose and resolve an action.
	"""
	if current_state == State.BATTLE_OVER:
		return

	add_to_turn_log("")
	var action = enemy_ai.choose_action_based_on_state()
	resolve_action(enemy, action, player)

	if current_state != State.BATTLE_OVER: 
		current_state = State. PLAYER_TURN


###EVENTS
func trigger_event():
	if not event_triggered and player.current_hp < 50 and randf() < 0.5:
		AudioManager.play_event_music_by_key("aaaa", false)
		add_to_turn_log("/n/n No... I can't fall here, I HAVE TO WIN! \n \n")
		player.stats["strength"] += 3
		event_triggered = true


func _on_light_attack_pressed() -> void:
	current_action = "light"
	process_turn(current_action)


func _on_heavy_attack_pressed() -> void:
	current_action = "heavy"
	process_turn(current_action)


func _on_use_skill_pressed() -> void:
	current_action = "use_skill"
	process_turn(current_action)


func _on_defend_pressed() -> void:
	current_action = "defend"
	process_turn(current_action)


func _on_dodge_pressed() -> void:
	current_action = "dodge"
	process_turn(current_action)


func _on_turn_pressed() -> void:
	current_action = "attack"
	process_turn(current_action)


func _on_magic_pressed() -> void:
	pass
