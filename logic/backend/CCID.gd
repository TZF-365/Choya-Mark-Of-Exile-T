extends Node
class_name CCID_

@onready var current_chapter_id: String = ""
@onready var current_page := ""

var time_accumulator := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_accumulator += _delta
	if time_accumulator >= 5.0:
		time_accumulator = 0.0
		print("⏱️ current_page:", current_page)

	
signal page_changed(new_page: String)

func set_page(new_page: String) -> void:
	current_chapter_id = new_page
	current_page = new_page
	print("Setting page:", new_page)  # Debug log
	emit_signal("page_changed", new_page)
