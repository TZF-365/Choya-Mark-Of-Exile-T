extends VBoxContainer
class_name Gamesc

#Declared entity node and connected it to 
@export var entity_var: Player_AL
@onready var player_stats = entity_var
var has_died = false

@onready var combat_initializer: CombatInstantiator = get_node("Combatmanager/CombatInstantiator")


@onready var anim_player: AnimationPlayer = $"../../../../../AnimationPlayer" # Ensure you have an AnimationPlayer node

var used_hp = false
var is_dead = false
var shown_death = false

#fade in variables
var fade_duration := 1.5 # seconds
var fade_timer := 0.0
var fading_in := false
var alpha = clamp(fade_timer / fade_duration, 0.0, 1.0)





@export var start_page:String = "000_prologue"
var death_page:String = "health_is_zero"
@export var mana_low_page:String = "mana_is_zero" #you can go ahead and implement something with this

# Declare variables for UI elements and connect them to their respective nodes in the scene
@onready var title_label: Label = %Label
@onready var statindicator: RichTextLabel = %StatIndicator
@onready var picture: TextureRect = %TextureRect
@onready var narr_text: RichTextLabel = %RichTextLabel
@onready var choices_con: VBoxContainer = %VBoxContainer
@onready var choice_1: PanelContainer = %ChoiceContainer
@onready var choice_2: PanelContainer = %ChoiceContainer2
@onready var choice_3: PanelContainer = %ChoiceContainer3
@onready var choice_4: PanelContainer = %ChoiceContainer4

# Variables to store the content data and the current page identifier
var content_dict: Dictionary
@onready var current_page

# Called when the node is added to the scene
func _ready() -> void:

	statindicator.text = ""
	content_dict = ContentData.content_dict
	Ccid.connect("page_changed", Callable(self, "_on_ccid_page_changed"))
	AudioManager.play_music(load("battlemusic"))

	# Only set start page if Ccid doesn't already have a value
	if Ccid.current_chapter_id == "":
		Ccid.set_page(start_page)
		
	current_page = Ccid.current_chapter_id
	set_content(content_dict[current_page])
	
	
	if content_dict.has(current_page):
		set_content(content_dict[current_page])
	else:
		print("Missing data reference for page:", current_page)

	# Connect choice button signals to the process_choice function
	choice_1.connect("choice_btn_pressed", Callable(self, "process_choice"))
	choice_2.connect("choice_btn_pressed", Callable(self, "process_choice"))
	choice_3.connect("choice_btn_pressed", Callable(self, "process_choice"))
	choice_4.connect("choice_btn_pressed", Callable(self, "process_choice"))


func handle_death():
	if has_died:
		return

	has_died = true
	is_dead = true

	print("Handling death sequence")

	current_page = death_page
	Ccid.set_page(death_page)
	set_content(content_dict[death_page])


func _process(_delta):
	player_stats = Player_AL

	if player_stats["val"] <= 0 and not has_died:
		handle_death()

	# Fade-in logic stays as-is
	if fading_in:
		fade_timer += _delta
		var alpha = clamp(fade_timer / fade_duration, 0.0, 1.0)
		narr_text.modulate.a = alpha
		if alpha >= 1.0:
			fading_in = false



func process_choice(choice_index: int) -> void:
	statindicator.text = ""

	# Ensure the current page exists
	if not content_dict.has(current_page):
		push_warning("Current page not found in content_dict: %s" % current_page)
		return

	var page_data: Dictionary = content_dict[current_page]
	var choice_key = str(choice_index)
	
	# Ensure the choice exists
	if not page_data["choices"].has(choice_key):
		push_warning("Choice index %s not found in page %s" % [choice_index, current_page])
		return

	var choice_data: Dictionary = page_data["choices"][choice_key]

	# --- HANDLE COMBAT ENCOUNTER ---
	if choice_data.has("load_combat_encounter"):
		var enc_data = choice_data["load_combat_encounter"]
		var enc: Dictionary = {}

		if typeof(enc_data) == TYPE_DICTIONARY:
			enc = enc_data
		elif typeof(enc_data) == TYPE_STRING:
			# For legacy string path
			enc = {"scene_path": enc_data}
		else:
			push_warning("Unexpected type for load_combat_encounter: %s" % typeof(enc_data))

		# Initialize CombatData safely
		CombatData.player = Player_AL
		CombatData.enemy_instance = null
		CombatData.enemy_id = ""
		CombatData.enemy_config = {}
		CombatData.battle_events = enc.get("battle_events", [])

		# Handle enemy instance if provided
		if enc.has("enemy_instance") and enc["enemy_instance"] != null:
			CombatData.enemy_instance = enc["enemy_instance"] as BaseChar

		# Handle enemy_id or enemy_scene
		if enc.has("enemy_id"):
			CombatData.enemy_id = str(enc["enemy_id"])
		if enc.has("enemy_scene"):
			var enemy_scene = load(enc["enemy_scene"])
			if enemy_scene:
				var enemy_instance = enemy_scene.instantiate() as BaseChar
				CombatData.enemy_instance = enemy_instance

		# Handle enemy_config overrides
		CombatData.enemy_config = {
			"override_display_name": enc.get("override_display_name", null),
			"override_hp": enc.get("override_hp", null),
			"override_stats": enc.get("override_stats", {}),
			"override_weapon": enc.get("override_weapon", null),
			"override_armor": enc.get("override_armor", null),
			"override_techniques": enc.get("override_techniques", [])
		}

		# Apply overrides immediately if instance exists
		if CombatData.enemy_instance != null:
			var e = CombatData.enemy_instance
			if CombatData.enemy_config["override_display_name"] != null:
				e.display_name = CombatData.enemy_config["override_display_name"]
			if CombatData.enemy_config["override_hp"] != null:
				e.max_hp = int(CombatData.enemy_config["override_hp"])
				e.current_hp = e.max_hp
			if CombatData.enemy_config["override_stats"].size() > 0:
				for k in CombatData.enemy_config["override_stats"]:
					e.stats[k] = CombatData.enemy_config["override_stats"][k]
			if CombatData.enemy_config["override_weapon"] != null:
				var w = load(CombatData.enemy_config["override_weapon"])
				if w: e.equip_weapon(w, "main_hand")
			if CombatData.enemy_config["override_armor"] != null:
				var a = load(CombatData.enemy_config["override_armor"])
				if a: e.equip_armor("chest", a)
			if CombatData.enemy_config["override_techniques"].size() > 0:
				e.techniques.clear()
				for tpath in CombatData.enemy_config["override_techniques"]:
					var tres = load(tpath)
					if tres:
						e.techniques.append(tres)

		# Transition to combat scene
		get_tree().change_scene_to_file("res://scenes/combat_screen.tscn")

	# --- HANDLE MUSIC CHANGE ---
	if page_data.has("music"):
		var music_path = page_data["music"]
		var music_stream = load(music_path)
		await AudioManager.fade_out_music()
		AudioManager.play_music(music_stream)

	# --- HANDLE SCENE CHANGE ---
	if page_data.has("scenechange"):
		var scene_path = page_data["scenechange"]
		get_tree().change_scene_to_file(scene_path)

	# --- HANDLE REQUIREMENTS AND BUFFS ---
	var output_value = choice_data.get("output", null)

	if choice_data.has("requirement"):
		var requirements = choice_data["requirement"]
		for key in requirements.keys():
			if player_stats.get(key) < requirements[key]:
				if choice_data.has("failed_output"):
					output_value = choice_data["failed_output"]

	if choice_data.has("buffs"):
		var buffs = choice_data["buffs"]
		for key in buffs.keys():
			var delta = buffs[key]
			if delta >= 0:
				statindicator.text += "\n[color=green]%s has increased by %s[/color]" % [key, str(delta)]
			else:
				statindicator.text += "\n[color=red]%s has decreased by %s[/color]" % [key, str(-delta)]
			player_stats[key] += delta

	# --- UPDATE PAGE ---
	if output_value != null:
		Ccid.set_page(output_value)
		current_page = output_value
		if content_dict.has(output_value):
			set_content(content_dict[output_value])
		else:
			push_warning("Output page not found: %s" % output_value)


# Function to set the content of the current page
func set_content(output_value) -> void:
	set_title(output_value)      # Set the title
	set_picture(output_value)    # Set the picture
	set_narr_text(output_value)  # Set the narrative text
	set_choice_btn(output_value) # Set the choice buttons



# Function to start a combat encounter
func start_combat_encounter(combat_data_path: String) -> void:
	# Preload the new scene and switch to it
	var combat_scene = preload("res://scenes/combat_screen.tscn")
	get_tree().change_scene_to_file("res://scenes/combat_screen.tscn")
	
# Function to initialize and transition to the combat encounter scene
func initialize_combat_scene(combat_data: Dictionary) -> void:
	var combat_scene = preload("res://scenes/combat_screen.tscn").instantiate()
	choice_1.connect("choice_btn_pressed", Callable(self, "process_choice"))
	get_tree().change_scene_to(combat_scene)

# Callback when combat ends
func _on_combat_ended(victory: bool) -> void:
	if victory:
		# Player won the combat, return to the narrative and proceed
		print("Combat won! Returning to narrative...")
		set_content(content_dict[current_page])  # Reload narrative content
	else:
		# Handle defeat (could be game over or retry)
		print("Combat lost! Handling defeat...")
		is_dead = true
		set_content(content_dict[death_page])



# Function to set the title text
func set_title(output_value) -> void:
	title_label.text = str(output_value["title"])

# Function to set the picture texture
func set_picture(output_value) -> void:
	if output_value.has("picture"):
		picture.texture = load(output_value["picture"])
	else:
		picture.texture = null
		
# Function to set the narrative text
func set_narr_text(output_value) -> void:
	narr_text.text = str(output_value["narr_text"])
	narr_text.modulate.a = 0.0  # Reset transparency
	fade_timer = 0.0
	fading_in = true

func run_actions(action_list: Array) -> void:
	for action in action_list:
		if action.begins_with("play_track:"):
			var path = action.split(":")[1]
			AudioManager.play_music(load(path))
		elif action == "fade_in_music":
			AudioManager.fade_in_music()
		elif action == "fade_out_music":
			AudioManager.fade_out_music()
		elif action == "stop_music":
			AudioManager.stop_music()
		# Add more actions as needed


func set_choice_btn(output_value) -> void:
	for choice_i in choices_con.get_children():
		choice_i.visible = false
		choice_i.set_text("")

	var source = output_value


	for choice in source["choices"]:
		match choice:
			"1":
				choice_1.set_text(source["choices"]["1"]["text"])
				choice_1.visible = true
			"2":
				choice_2.set_text(source["choices"]["2"]["text"])
				choice_2.visible = true
			"3":
				choice_3.set_text(source["choices"]["3"]["text"])
				choice_3.visible = true
			"4":
				choice_4.set_text(source["choices"]["4"]["text"])
				choice_4.visible = true



func _on_page_changed(new_page: String) -> void:
	if content_dict.has(new_page):
		set_content(content_dict[new_page])


func _on_ccid_page_changed(new_page: String) -> void:
	if content_dict.has(new_page):
		set_content(content_dict[new_page])
		
		
		
		
		
		
