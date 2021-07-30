tool
extends ColorRect

export (NodePath) var render_viewport_path

var editor_interface: EditorInterface
var grabbing := false
var scene_offset := Vector2()


func _gui_input(event):
	if event is InputEventMouseButton:
		
		var viewport : Viewport = get_node(render_viewport_path)
		var scene = viewport.get_child(0)
		var texture_rect := $Viewport/TextureRect
		
		if event.button_index == BUTTON_WHEEL_UP:
			$Viewport.canvas_transform = $Viewport.canvas_transform.scaled(Vector2(1.1,1.1))
		if event.button_index == BUTTON_WHEEL_DOWN:
			$Viewport.canvas_transform = $Viewport.canvas_transform.scaled(Vector2(0.9,0.9))
		
		var mouse_pos_in_viewport : Vector2 = $Viewport.canvas_transform.affine_inverse() * get_local_mouse_position()
		print(mouse_pos_in_viewport)
		print(texture_rect.get_rect())
		if event.button_index == BUTTON_LEFT:

			if event.is_pressed():
				if texture_rect.get_rect().has_point(mouse_pos_in_viewport):
					grabbing = true
					scene_offset = texture_rect.rect_position - mouse_pos_in_viewport
			else:
				grabbing = false


func _process(delta):
	var viewport : Viewport = get_node(render_viewport_path)
	var viewport_image := viewport.get_texture().get_data()
	viewport_image.flip_y()
	viewport_image = viewport_image.get_rect(viewport_image.get_used_rect())
	var texture := ImageTexture.new()
	texture.create_from_image(viewport_image)
	$Viewport/TextureRect.rect_size = viewport_image.get_size()
	$Viewport/TextureRect.texture.flags = 0
	$Viewport/TextureRect.texture = texture
	
	if grabbing:
		var mouse_pos_in_viewport : Vector2 = $Viewport.canvas_transform.affine_inverse()*get_local_mouse_position()
		viewport.get_child(0).position = mouse_pos_in_viewport + scene_offset
		$Viewport/TextureRect.rect_position = mouse_pos_in_viewport + scene_offset

