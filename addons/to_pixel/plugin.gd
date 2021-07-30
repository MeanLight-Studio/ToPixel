tool
extends EditorPlugin

var main_widget

func _enter_tree():
	main_widget = preload("res://addons/to_pixel/ToPixel.tscn").instance()
	get_editor_interface().get_editor_viewport().add_child(main_widget)
	
	make_visible(false)


func _exit_tree():
	main_widget.queue_free()


func has_main_screen():
	return true


func get_plugin_name():
	return "ToPixel"

func make_visible(visible):
	if visible:
		main_widget.show()
	else:
		main_widget.hide()

