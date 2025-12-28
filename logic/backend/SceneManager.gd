extends Node
class_name SceneManage

var overlay_scene: Node = null

func change(path: String) -> void:
	var tree := get_tree()
	if tree == null:
		push_error("SceneTree is null")
		return

	tree.change_scene_to_file(path)

# For stuff like menu overlay, death screens and I guess also videos and stuff
func push_scene_on_top(path: String, pause_below := true) -> void:
	if overlay_scene and is_instance_valid(overlay_scene):
		return # already active

	var packed := load(path)
	if packed == null:
		push_error("Failed to load scene")
		return

	overlay_scene = packed.instantiate()

	if pause_below and get_tree().current_scene:
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED

	get_tree().root.add_child(overlay_scene)

# for POOFING a overlay scene into oblivion btw
func pop_scene() -> void:
	if overlay_scene == null or not is_instance_valid(overlay_scene):
		return

	overlay_scene.queue_free()
	overlay_scene = null

	if get_tree().current_scene:
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT

func change_scene_with_delay(scene_path: String, delay_sec: float = 3.0):
	print("Waiting before changing scene...")
	await get_tree().create_timer(delay_sec).timeout
	get_tree().change_scene_to_file(scene_path)
	print("Scene changed!")

func wait():
	await get_tree().create_timer(3.0).timeout
