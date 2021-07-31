tool
extends ColorRect

export (NodePath) var render_viewport_path

var editor_interface: EditorInterface
var grabbing := false
var grabbing_canvas := false
var scene_offset := Vector2()
var canvas_grab_offset := Vector2()
var mouse_pos_in_viewport := Vector2()
var zoom_level := 1.0

func _gui_input(event):
	if event is InputEventMouseButton:
		
		var viewport : Viewport = get_node(render_viewport_path)
		var texture_rect := $Viewport/TextureRect
		var canvas := $TextureRect
		
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_level *= 1.1
			canvas.rect_position += -0.1*(get_local_mouse_position() - canvas.rect_position)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_level *= 0.9
			canvas.rect_position += 0.1*(get_local_mouse_position() - canvas.rect_position)
			
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				if texture_rect.get_rect().has_point(mouse_pos_in_viewport):
					$ReferenceRect.visible = true
					grabbing = true
					scene_offset =  texture_rect.rect_position - mouse_pos_in_viewport
				else:
					$ReferenceRect.visible = false
					if canvas.get_rect().has_point(get_local_mouse_position()):
						grabbing_canvas = true
						canvas_grab_offset = canvas.rect_position - get_local_mouse_position()
			else:
				grabbing = false
				grabbing_canvas = false


func _process(delta):
	mouse_pos_in_viewport = 1/zoom_level * (get_local_mouse_position() - $TextureRect.rect_position)
	var canvas := $TextureRect
	var viewport : Viewport = get_node(render_viewport_path)
	$TextureRect.rect_size = $Viewport.size * zoom_level
	var viewport_image := viewport.get_texture().get_data()
	viewport_image.flip_y()
	viewport_image = viewport_image.get_rect(viewport_image.get_used_rect())
	var texture := ImageTexture.new()
	texture.create_from_image(viewport_image)
	$Viewport/TextureRect.rect_size = viewport_image.get_size()
	
	$Viewport/TextureRect.texture = texture
	$Viewport/TextureRect.texture.flags = 0
	

	if grabbing:
		$Viewport/TextureRect.rect_position = mouse_pos_in_viewport + scene_offset
		
	$ReferenceRect.rect_size = $Viewport/TextureRect.rect_size*zoom_level
	$ReferenceRect.rect_position = ($Viewport/TextureRect.rect_position*zoom_level + $TextureRect.rect_position)
	
	if grabbing_canvas:
		canvas.rect_position = get_local_mouse_position() + canvas_grab_offset
