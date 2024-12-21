extends CanvasLayer

@onready var message = $Message
@export var ITEM : Item


func _ready():
	var labeltext = $Label.text 
	$Label.text  = "pizza"
	


func _on_button_pressed() -> void: #when the button is pressed the logged item is pasted over and over
	print('butten pressed')
	$Label.text  = "pizzaaaaaa"
