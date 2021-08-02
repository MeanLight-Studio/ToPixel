tool
extends ColorRect

export (NodePath) var render_viewport_path

var editor_interface: EditorInterface
var grabbing := false
var grabbing_canvas := false
var scene_offset := Vector2()
var scene_pivot := Vector2()
var scene_position := Vector2()
var canvas_grab_offset := Vector2()
var mouse_pos_in_viewport := Vector2()
var zoom_level := 1.0
var need_to_update := false


func _gui_input(event):
	if grabbing and event is InputEventMouseMotion:
		need_to_update = need_to_update or true
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
					scene_offset =  scene_position - mouse_pos_in_viewport
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
	$TextureRect.rect_size = $Viewport.size * zoom_level
	
	if grabbing:
		scene_position = (mouse_pos_in_viewport + scene_offset)

	$ReferenceRect.rect_size = $Viewport/TextureRect.rect_size*zoom_level
	$ReferenceRect.rect_position = ($Viewport/TextureRect.rect_position*zoom_level + $TextureRect.rect_position)
	
	if grabbing_canvas:
		canvas.rect_position = get_local_mouse_position() + canvas_grab_offset
		
	if need_to_update:
		need_to_update = false
		update()
	
func update():
	var viewport : Viewport = get_node(render_viewport_path)
	var origin : Position2D = viewport.get_node("Origin")
	var viewport_image := viewport.get_texture().get_data()
	var used_rect := viewport_image.get_used_rect()
	if used_rect.size > Vector2.ZERO:
		viewport_image.flip_y()
		used_rect = viewport_image.get_used_rect()
		viewport_image = viewport_image.get_rect(used_rect)
		var texture := ImageTexture.new()
		texture.create_from_image(viewport_image)
		$Viewport/TextureRect.rect_size = viewport_image.get_size()
		$Viewport/TextureRect.texture = texture
		$Viewport/TextureRect.texture.flags = 0
		scene_pivot = used_rect.position - origin.position
		$Viewport/TextureRect.rect_position = (scene_pivot + scene_position).snapped(Vector2.ONE)


func _on_ColorRect_resized():
	$TextureRect/ColorRect.material.set_shader_param("rect_size", $TextureRect/ColorRect.rect_size/zoom_level)
