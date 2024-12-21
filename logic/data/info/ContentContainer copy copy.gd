extends VBoxContainer


var player_stats : Dictionary

var used_hp = false
var is_dead = false
var shown_death = false

# Declare variables for UI elements and connect them to their respective nodes in the scene
@onready var title_label: Label = %Label
@onready var statindicator: RichTextLabel = %StatIndicator
@onready var display: RichTextLabel = %RichTextLabel
@onready var choices_con: VBoxContainer = %VBoxContainer
@onready var choice_1: PanelContainer = %ChoiceContainer
@onready var choice_2: PanelContainer = %ChoiceContainer2
@onready var choice_3: PanelContainer = %ChoiceContainer3
@onready var choice_4: PanelContainer = %ChoiceContainer4

# Variables to store the content data and the current page identifier
var content_dict: Dictionary
var current_page: String

# Called when the node is added to the scene
func _ready() -> void:
	statindicator.text = ""
	# Initialize the content dictionary from an external source
	content_dict = ContentData.content_dict


	# Connect choice button signals to the process_choice function
	choice_1.connect("choice_btn_pressed", Callable(self, "process_choice"))
	choice_2.connect("choice_btn_pressed", Callable(self, "process_choice"))
	choice_3.connect("choice_btn_pressed", Callable(self, "process_choice"))
	choice_4.connect("choice_btn_pressed", Callable(self, "process_choice"))


# Function to set the title text
func set_title(output_value) -> void:
	title_label.text = str(output_value["title"])


# Function to append formatted messages to the RichTextLabel
func print_to_log(message: String) -> void:
	display.append_bbcode(message + "\n")


func _on_button_pressed() -> void:
	# Print a simple message with bold, green text
	print_to_log("[color=green][b]Player takes 10 damage![/b][/color]")
	
	# Print a message with italic, red text
	print_to_log("[color=red][i]Player's health is low![/i][/color]")
	
	# Print a message with large, underlined text
	print_to_log("[size=20][u]Healing Potion used![/u][/size]")
	
	# Print a message with a custom font and size
	print_to_log("[font=Arial][size=24]You have leveled up![/size][/font]")
