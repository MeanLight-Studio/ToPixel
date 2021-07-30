tool
extends Viewport

signal scene_changed(used_rect)


func add_scene(scene_path : String):
	for child in get_children():
		child.queue_free()
	var scene = load(scene_path).instance()
	add_child(scene)
	scene.global_position = size/2
	yield(VisualServer, "frame_post_draw")
	var image : Image = get_texture().get_data()
	emit_signal("scene_changed", image.get_used_rect())



func _on_Button_pressed():
	add_scene("res://Sprite.tscn")
