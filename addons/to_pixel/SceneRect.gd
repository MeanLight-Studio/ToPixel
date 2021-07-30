tool
extends ReferenceRect

var grabbing := false
var offset := Vector2.ZERO

export (NodePath) var viewport_path

func _process(delta):
	if get_node(viewport_path).get_child_count() == 0:
		return
	var scene := get_node(viewport_path).get_child(0)
	if grabbing and scene:
		rect_position = get_global_mouse_position() + offset
		scene.position = rect_position + rect_size/2


func _on_SceneRect_resized():
	get_node(viewport_path).get_child(0).position = rect_position + rect_size/2


func _on_SceneRect_gui_input(event):
	if event is InputEventMouseButton:
		print("asdf")
		if event.button_index == BUTTON_LEFT:
			grabbing = event.is_pressed()
			offset = rect_position - get_global_mouse_position()

func set_scene_rect(rect : Rect2):
	rect_position = rect.position
	rect_size = rect.size
