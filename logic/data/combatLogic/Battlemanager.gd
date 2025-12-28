extends Node
class_name CombatManager_

# Player and enemy character references
var player: BaseChar = Player_AL
@export var enemy:  BaseChar

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


func _apply_enemy_overrides(enemy: BaseChar, config: Dictionary) -> void:
	if config.has("override_display_name") and config["override_display_name"] != null:
		enemy.display_name = config["override_display_name"]
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


# Resolve all actions
func resolve_action(actor: BaseChar, action: String, target: BaseChar):
	var log_entry := ""
	var is_attack := true	
	print("\n--- Resolving action: %s by %s targeting %s ---"
		% [action, actor.display_name, target.display_name])


	# STANCE ACTIONS (NO ATTACK)
	if action == "defend":
		actor.is_defending = true
		log_entry = "%s prepares to defend. " % actor.display_name
		#add_to_turn_log(log_entry)
		is_attack = false

	if action == "dodge":
		actor.is_dodging = true
		log_entry = "%s becomes evasive. " % actor.display_name
		#add_to_turn_log(log_entry)
		is_attack = false
		
	# SKILL ACTIONS
	if action == "use_skill":
		# Example: active combat skills
		actor.use_selected_skill(target)
		return

	if is_attack:
		var attack_type := action
		var damage := 0

		var chosen_technique = choose_technique(actor, target, attack_type)

		if chosen_technique != null:
			log_entry += "%s uses %s! " % [actor.display_name, chosen_technique.name]
			damage = damage_calc(actor, target, attack_type, chosen_technique)
		else:
			damage = damage_calc(actor, target, attack_type)

		target.current_hp -= damage
		target.current_hp = clamp(target.current_hp, 0, target.max_hp)

		log_entry += generate_attack_description(actor, target, damage)

		# Consume stances ONLY when attacked
		target.is_dodging = false
		target.is_defending = false



	print("Target Momentum:", target.momentum)

	# ============================

	if not target.finisher_available and target.momentum >= target.finisher_available:
		target.finisher_active = true
		add_to_turn_log(
			"%s is vulnerable — a **Finisher** is now possible!"
			% target.display_name
		)

	elif not target.opportunity_available and target.momentum >= target.opportunity_available:
		target.opportunity_active = true
		add_to_turn_log(
			"%s shows weakness — an **Opportunity Attack** is possible!"
			% target.display_name
		)

	print("Target HP after damage: %d / %d"
		% [target.current_hp, target.max_hp])

	add_to_turn_log(log_entry)
	update_health_labels()
	check_battle_end()


	process_stamina_endurance(actor, action)



func trigger_auto_counter(attack_type: String, vulnerable_target: BaseChar, attacker: BaseChar):
	print("Checking if %s can auto-retaliate with a %s technique on %s" % [attacker.display_name, attack_type, vulnerable_target.display_name])

	if attack_type == "opportunity" and attacker.opportunity_used_this_turn: 
		print("Opportunity already used by %s this turn. Skipping." % attacker.display_name)
		return
	if attack_type == "finisher" and attacker.finisher_used_this_turn:
		print("Finisher already used by %s this turn. Skipping." % attacker.display_name)
		return

	for technique in attacker.techniques:
		print("Checking technique: %s (%s) [Cooldown: %s]" % [technique.name, technique.technique_type, str(technique.on_cooldown)])
		if technique.technique_type == attack_type and not technique.on_cooldown:
			print("%s uses %s (%s) on %s!" % [attacker.display_name, technique.name, attack_type, vulnerable_target.display_name])

			damage = damage_calc(attacker, vulnerable_target, attack_type, technique)
			vulnerable_target.current_hp -= damage
			vulnerable_target.current_hp = clamp(vulnerable_target.current_hp, 0, vulnerable_target.max_hp)

			var logger = "%s sees an opening and uses %s on %s!" % [attacker. display_name, technique.name, vulnerable_target.display_name]
			add_to_turn_log(logger + " " + generate_attack_description(attacker, vulnerable_target, damage))
			update_health_labels()

			if attack_type == "opportunity":
				attacker.opportunity_used_this_turn = true
			elif attack_type == "finisher":
				attacker.finisher_used_this_turn = true

			technique.trigger_cooldown()
			return  # Only one retaliation per type per turn

	print("No valid %s technique available for %s to use." % [attack_type, attacker.display_name])


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

		return techniques
		print(techniques, "Is found")

	print("No valid technique found for %s (attack type: %s). Techniques checked: %d"
		% [actor.display_name, attack_type, actor.techniques.size()])
	return null


func decay_momentum(actor: BaseChar):
	if actor.momentum <= 0:
		return

	var health_ratio = float(actor.current_hp) / actor.max_hp
	var stamina_ratio = float(actor. current_stamina) / actor.max_stamina

	var condition = (stamina_ratio * 0.7) + (health_ratio * 0.3)
	var max_decay = lerp(2, 5, condition)
	var decay_amount = randi_range(2, int(max_decay))

	print("--- Momentum Decay Report ---")
	print("Actor:", actor.name)
	print("Health:", actor.current_hp, "/", actor.max_hp, "(", round(health_ratio * 100.0), "% )")
	print("Stamina:", actor.current_stamina, "/", actor.max_stamina, "(", round(stamina_ratio * 100.0), "% )")
	print("Weighted Condition Score:", round(condition * 100.0), "%")
	print("Calculated Decay Range:  2 to ", int(max_decay))
	print("Final Momentum Lost:", decay_amount)
	print("Reason: Condition-based momentum decay (stamina-weighted)")
	print("-----------------------------\n")

	adjust_momentum(actor, -decay_amount, "condition-based momentum decay")


func process_stamina_endurance(actor: BaseChar, action: String) -> void:
	var is_attacking = action == "light" or action == "heavy"

	if is_attacking:
		var weapon_power = actor.get_weapon_power()
		var strength = actor.stats.get("strength", 0)
		var stamina_cost = int(1.2 * weapon_power + 0.2 + strength )
		actor.current_stamina -= stamina_cost
		print("🗡️", actor.name, "performed", action, "- Stamina cost:", stamina_cost)
	else:
		actor.stamina += 5
		print("💨", actor.name, "rested - Stamina recovered:  +5")

	actor.stamina = clamp(actor.stamina, 0, actor.max_stamina)
	print("📊", actor.name, "Stamina after update:", actor.stamina, "/", actor.max_stamina)

	var stamina_ratio = float(actor. stamina) / float(actor.max_stamina)

	if stamina_ratio < 0.5:
		var loss = 0.005 * actor.max_endurance
		actor.endurance -= loss
		print("⚠️", actor.name, "low stamina - Endurance decreased by", loss)
	elif stamina_ratio > 0.75:
		var gain = 0.003 * actor.max_endurance
		actor.endurance += gain
		print("💪", actor.name, "high stamina - Endurance increased by", gain)
	else:
		print("⏸️", actor.name, "mid-range stamina - Endurance unchanged")

	actor.endurance = clamp(actor.endurance, 0.0, actor.max_endurance)
	print("📈", actor.name, "Endurance after update:", actor.endurance, "/", actor.max_endurance)


func reset_combat_states(character: BaseChar):
	character.is_defending = false
	character.is_dodging = false
	decay_momentum(character)


##LOGGING
func add_to_turn_log(text: String):
	"""
	Adds text to the turn log buffer. Logs are collected and displayed at the end of the turn.
	"""
	turn_log += text + " "


func finalize_turn_log():
	"""
	Appends the collected turn log to the combat log and clears the buffer for the next turn.
	"""
	if turn_log.strip_edges() != "":
		combat_log.append_text("%s\n\n" % turn_log.strip_edges())
		turn_log = ""
	update_health_labels()


func damage_calc(actor: BaseChar, target: BaseChar, attack_type: String, technique: Technique_ = null) -> int:
	var attack_power = actor.stats["strength"] * 2.7 + actor.get_weapon_power()
	var multiplier = get_final_multiplier(actor, target, attack_type, technique)
	var base_damage = attack_power * multiplier
	print("🔸 Attack Power:  %.2f, Multiplier: %.2f, Base Damage: %.2f" % [attack_power, multiplier, base_damage])

	var armor_reduction = apply_armor_reduction(target, attack_power)
	print("🛡️ Armor Reduction: %.2f" % armor_reduction)
	base_damage -= armor_reduction
	print("🔻 Damage After Armor: %.2f" % base_damage)

	if target.is_defending:
		# Random reduction between 50% and 100%
		# Final damage multiplier is between 0.0 and 0.5
		var reduction := randf_range(0.5, 1.0)
		base_damage *= (1.0 - reduction)
		var description := generate_attack_description(actor, target, base_damage)
		add_to_turn_log(description)
		print("defended")

	elif target.is_dodging:
		# 80% chance to take no damage at all
		if randf() < 0.8:
			base_damage = 0
			var description := generate_attack_description(actor, target, base_damage)
			add_to_turn_log(description)
			print("dodged")

		else:
			var description := generate_attack_description(actor, target, base_damage)
			add_to_turn_log(description)
			print("took hit")

	var defense_modifier = target.stats["toughness"] * 1.64
	var final_damage = max(int(base_damage - defense_modifier), 0)
	print("🧱 Toughness Reduction: %.2f, Final Damage: %d" % [defense_modifier, final_damage])

	update_armor_durability(target, attack_power)

	return final_damage


func apply_armor_reduction(target: BaseChar, attack_power: float) -> float:
	if target.armor_slots == null:
		return 0.0

	var total_reduction := 0.0
	var broken_armor_slots := []

	for armor_piece in target.armor_slots. values():
		if armor_piece is ItemResource: 
			if armor_piece.broken:
				continue

			var percent_reduction:  float = armor_piece.damage_reduction
			var durability_factor: float = float(armor_piece.durability) / armor_piece.max_durability
			var scaled_reduction:  float = percent_reduction * durability_factor
			var reduced_amount: float = attack_power * scaled_reduction

			total_reduction += reduced_amount

			print("%s's %s reduces damage by %.2f (%. 0f%% x %. 0f%%)!" % [
				target.display_name,
				armor_piece.slot_name,
				reduced_amount,
				percent_reduction * 100,
				durability_factor * 100
			])

			if durability_factor < 0.303:
				if randi() % 100 < 50:
					add_to_turn_log("%s's %s Armor breaks due to low durability!" % [target.display_name, armor_piece.name])
					armor_piece.broken = true
					broken_armor_slots.append(armor_piece. slot_name)
					print("🧪 Break check — durability factor:", durability_factor)

	for slot_name in broken_armor_slots: 
		target.armor_slots. erase(slot_name)

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
			multiplier *= 1.02
		"heavy":
			multiplier *= 1.2
		"special":
			multiplier *= 1.4
		"finisher":
			multiplier *= 1.7

	# Apply low HP bonus multiplicatively

	return multiplier



@warning_ignore("shadowed_variable")
func generate_attack_description(actor: BaseChar, target: BaseChar, damage: int) -> String:
	var description:  String = ""

	if target. is_dodging:
		if damage > 0:
			var dodging_hit = [
				"%s tries to dodge %s but gets clipped for %d damage.",
				"%s gets hit while dodging — %d damage.",
				"%s almost evades %s's strike but takes %d damage anyway! ",
				"%s stumbles mid-dodge and takes %d from %s.",
				"%s nearly evades %s, but still takes %d."
			]
			var choice := randi() % dodging_hit.size()
			match choice:
				0, 2, 4:
					description = dodging_hit[choice] % [target.display_name, actor.display_name, damage]
				1:
					description = dodging_hit[choice] % [target.display_name, damage]
				3:
					description = dodging_hit[choice] % [target.display_name, damage, actor.display_name]
		else:
			var dodging_miss = [
				"%s expertly dodges %s's attack, taking no damage!",
				"%s sidesteps the strike.",
				"%s sidesteps %s's strike with ease, emerging unscathed!",
				"%s dodges %s cleanly.",
				"%s evades the attack."
			]
			var choice := randi() % dodging_miss.size()
			match choice:
				0, 2, 3:
					description = dodging_miss[choice] % [target. display_name, actor.display_name]
				1, 4:
					description = dodging_miss[choice] % [target.display_name]

	elif target.is_defending:
		if damage > 0:
			var defending_hit = [
				"%s braces for %s's attack, but the force breaks through for %d damage!",
				"%s guards but takes a reduced %d from %s.",
				"%s holds their ground, and %s's strike lands for %d damage!",
				"%s's guard falters — %d damage.",
				"%s's guard weakens as %s's blow connects for %d damage! ",
				"%s braces, still takes %d."
			]
			var choice := randi() % defending_hit.size()
			match choice:
				0, 2, 4:
					description = defending_hit[choice] % [target.display_name, actor.display_name, damage]
				1:
					description = defending_hit[choice] % [target.display_name, damage, actor.display_name]
				3, 5:
					description = defending_hit[choice] % [target.display_name, damage]
		else:
			var defending_block = [
				"%s blocks %s completely.",
				"%s deflects the attack.",
				"%s raises their guard and nullifies %s's strike with precision!",
				"%s's guard holds firm.",
				"%s deflects %s's blow effortlessly, taking no damage! ",
				"%s shrugs off the blow."
			]
			var choice := randi() % defending_block.size()
			match choice:
				0, 2, 4:
					description = defending_block[choice] % [target.display_name, actor.display_name]
				1, 3, 5:
					description = defending_block[choice] % [target.display_name]

	else:
		if damage > 0:
			var normal_hit = [
				"%s hits %s for %d.",
				"%s strikes — %d damage to %s.",
				"%s lands a hit on %s (%d).",
				"%s wounds %s for %d.",
				"%s attacks %s, dealing %d."
			]
			var choice := randi() % normal_hit.size()
			match choice:
				0, 3, 4:
					description = normal_hit[choice] % [actor.display_name, target.display_name, damage]
				1: 
					description = normal_hit[choice] % [actor.display_name, damage, target.display_name]
				2:
					description = normal_hit[choice] % [actor.display_name, target.display_name, damage]
		else:
			var normal_miss = [
				"%s swings at %s but misses entirely!",
				"%s's attack fails to connect with %s!",
				"%s's attack whiffs.",
				"%s misjudges the strike, missing %s completely!",
				"%s dodges just in time.",
				"%s misses"
			]
			var choice := randi() % normal_miss.size()
			match choice:
				0, 1, 3:
					description = normal_miss[choice] % [actor.display_name, target.display_name]
				4:
					description = normal_miss[choice] % [target.display_name]
				2, 5:
					description = normal_miss[choice] % [actor.display_name]
	return description


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
		finalize_turn_log()
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
	if not event_triggered and player.current_hp < 50 and randf() < 1.0:
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
