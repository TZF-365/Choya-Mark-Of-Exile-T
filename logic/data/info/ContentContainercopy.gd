extends Control

# Export the UI elements so they can be assigned in the editor
@export var input_field: LineEdit
@export var output_label: RichTextLabel

# Called when the scene enters the tree for the first time.
func _on_input_field_text_submitted(new_text: String) -> void:
	# Connect the text_entered signal from LineEdit directly to the function
	input_field.text_submitted.connect(_on_text_entered)


# Function that gets triggered when text is entered in the input field
func _on_text_entered(new_text: String):
	# If the new text is not empty, append it to the output label
	if new_text.strip_edges() != "":
		output_label.append_bbcode("[color=white]" + new_text + "[/color]\n")  # Display the text in the label
		input_field.clear()  # Clear the input field for the next entry


# Variable to store the submitted text
var submitted_text: String = ""


# Function that gets triggered when the submit button is pressed
func _on_submit_button_pressed():
	# Get the text from the input field
	var input_text = input_field.text.strip_edges()  # Remove leading/trailing spaces
	
	# Store the input text in the submitted_text variable if it's not empty
	if input_text != "":
		submitted_text = input_text
		
		# Optionally print or display the submitted text in the command line
		print("Submitted Text: ", submitted_text)
		
		# Clear the input field after submitting the text
		input_field.clear()
