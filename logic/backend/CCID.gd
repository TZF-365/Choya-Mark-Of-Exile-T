extends Node
class_name CCID_

var current_chapter_id: String = ""
var current_page := ""
var content_dict: Dictionary = {} 

var time_accumulator := 0.0

signal page_changed(new_page: String)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	time_accumulator += _delta
	if time_accumulator >= 5.0:
		time_accumulator = 0.0
		print("⏱️ current_page:", current_page)

func set_page(new_page: String) -> void:
	current_chapter_id = new_page
	current_page = new_page
	print("Setting page:", new_page)
	emit_signal("page_changed", new_page)

func set_content(content: String) -> void:
	if has_node("RichTextLabel"):
		%RichTextLabel.text = content

# 🔧 New method: Set full content dictionary
func set_content_dict(new_dict: Dictionary) -> void:
	content_dict = new_dict

# 🔧 New method: Update text from current_page
func set_content_from_current_page() -> void:
	if content_dict.has(current_page):
		set_content(content_dict[current_page])
