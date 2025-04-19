extends VBoxContainer
class_name Gamesc

#Declared entity node and connected it to 
@export var entity_var: Player_AL
@onready var player_stats = entity_var

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
@export var death_page:String = "health_is_zero"
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


func _process(_delta):
	
	player_stats = Player_AL
	if player_stats["current_val"] <=0:
		is_dead = true 
		
	if is_dead and shown_death == false:
		var death_text = str(content_dict[death_page]["narr_text"])+"\n"
		print("death text is ",death_text)
		narr_text.text = narr_text.text+"\n"+death_text
		var output =content_dict[death_page]["choices"][str(1)]
		print(output)
		set_choice_btn(content_dict[death_page])
		shown_death=true	

		Ccid.set_page(current_page)  # Ensure global page is updated here
		set_content(content_dict[current_page])	

	# ✅ FADE IN LOGIC
	if fading_in:
		fade_timer += _delta
		var alpha = clamp(fade_timer / fade_duration, 0.0, 1.0)
		narr_text.modulate.a = alpha
		if alpha >= 1.0:
			fading_in = false




# Function to process a choice made by the user
func process_choice(choice_index: int) -> void:
	statindicator.text = ""

	if is_dead:
		current_page = death_page
			
		
	var choice_data = content_dict[current_page]["choices"][str(choice_index)]
	
	# Check if the choice includes a combat encounter
	if choice_data.has("load_combat_encounter"):
		var combat_data_path = choice_data["load_combat_encounter"]
		start_combat_encounter(combat_data_path)
		return

	if content_dict[current_page]["choices"][str(choice_index)].has("output"):
		get_parent().scroll_vertical = 0
		var output_value = content_dict[current_page]["choices"][str(choice_index)]["output"]

		if content_dict[current_page]["choices"][str(choice_index)].has("requirement"):
			var requirements = content_dict[current_page]["choices"][str(choice_index)]["requirement"]
			for requirement in requirements.keys():
				if player_stats[requirement] < requirements[requirement] and content_dict[current_page]["choices"][str(choice_index)].has("failed_output"):
					if requirement == "mana":
						var health_deduction = player_stats[requirement] - requirements[requirement]
						player_stats["current_val"] += round(health_deduction * 1.5)
						statindicator.text += "\n[color=red]" + str("health") + " has decreased by " + str(round(-health_deduction * 1.5)) + "[/color]"
						used_hp = true
						output_value = content_dict[current_page]["choices"][str(choice_index)]["output"]
					else:
						output_value = content_dict[current_page]["choices"][str(choice_index)]["failed_output"]

		if content_dict[current_page]["choices"][str(choice_index)].has("buffs"):
			var buff_value = content_dict[current_page]["choices"][str(choice_index)]["buffs"]
			for key in buff_value.keys():
				if buff_value[key] >= 0:
					statindicator.text += "\n[color=green]" + key + " has increased by " + str(buff_value[key]) + "[/color]"
				else:
					statindicator.text += "\n[color=red]" + key + " has decreased by " + str(-buff_value[key]) + "[/color]"
				player_stats[key] += buff_value[key]

		# Update current page and load content
		Ccid.set_page(output_value)
		current_page = output_value  # Optional, just for local convenience
		set_content(content_dict[output_value])


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
		process_choice(1)  # Assuming 1 leads to the death path


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



# Function to set the choice buttons
func set_choice_btn(output_value) -> void:
	# Hide all choice buttons initially
	for choice_i in choices_con.get_children():
		if choice_i.visible:
			choice_i.set_text("")
			choice_i.visible = false
			
	# Display and set text for each choice button based on the current content
	if is_dead == false:
		for choice in output_value["choices"]:
			match choice:
				"1":
					choice_1.set_text(str(output_value["choices"][str(choice_1.choice_index)]["text"]))
					choice_1.visible = true
				"2":
					choice_2.set_text(str(output_value["choices"][str(choice_2.choice_index)]["text"]))
					choice_2.visible = true
				"3":
					choice_3.set_text(str(output_value["choices"][str(choice_3.choice_index)]["text"]))
					choice_3.visible = true
				"4":
					choice_4.set_text(str(output_value["choices"][str(choice_4.choice_index)]["text"]))
					choice_4.visible = true
					
	elif is_dead == true:
		for choice in content_dict[death_page]["choices"]:
			match choice:
				"1":
					choice_1.set_text(str(content_dict[death_page]["choices"][str(choice_1.choice_index)]["text"]))
					choice_1.visible = true
				"2":
					choice_2.set_text(str(content_dict[death_page]["choices"][str(choice_2.choice_index)]["text"]))
					choice_2.visible = true
				"3":
					choice_3.set_text(str(content_dict[death_page]["choices"][str(choice_3.choice_index)]["text"]))
					choice_3.visible = true
				"4":
					choice_4.set_text(str(content_dict[death_page]["choices"][str(choice_4.choice_index)]["text"]))
					choice_4.visible = true



func _on_page_changed(new_page: String) -> void:
	if content_dict.has(new_page):
		set_content(content_dict[new_page])


func _on_ccid_page_changed(new_page: String) -> void:
	if content_dict.has(new_page):
		set_content(content_dict[new_page])
		
		
		
		
		
		
