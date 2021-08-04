tool
extends Control

var fps := 12.0

onready var canvas := $HBoxContainer/ViewportBackground/TextureRect
onready var ui := $HBoxContainer/UI
onready var origin := $Viewport/Origin
onready var viewport := $Viewport
onready var texture_in_viewport := $HBoxContainer/ViewportBackground/Viewport/TextureRect
onready var viewport_background := $HBoxContainer/ViewportBackground

func export_aseprite():
	var ase_ex := AsepriteExporter.new()
	
	ase_ex.frame_duration_ms = 1.0/fps*1000
	
	ase_ex.set_canvas_size_px(canvas.rect_size.x, canvas.rect_size.y)
	var animations : Array = ui.get_animations(true)
	var layers : Dictionary = ui.get_layers()
	var animation_player : AnimationPlayer = ui.get_current_animation_player()
	
	ase_ex.define_layers(layers.keys())
	
	var from_frame := 0
	var tags := []
	for animation_name in animations:
		var animation : Animation = animation_player.get_animation(animation_name)
		var frame_count := int(animation.length * fps)
		var tag := [animation_name, from_frame, from_frame+frame_count]
		from_frame += frame_count + 1
		tags.append(tag)
		
	ase_ex.define_tags(tags)
	# Get sprite array
	
	var sprites := []
	
	for layer in layers:
		for path in layers[layer]:
			var sprite = origin.get_node(path)
			sprites.append(sprite)
			sprite.self_modulate = Color.transparent
			
	VisualServer.force_draw(true)
	var image : Image
	
	var im := 0
	for animation_name in animations:
		animation_player.current_animation = animation_name
		var animation : Animation = animation_player.get_animation(animation_name)
		animation_player.stop()
		var t := 0.0
		while t <= animation.length:
			animation_player.seek(t, true)
			canvas.get_parent().need_to_update = true
			
			for layer in layers:
				for path in layers[layer]:
					origin.get_node(path).self_modulate = Color.white
					
				yield(VisualServer,"frame_post_draw")
				
				var texture : Texture = viewport.get_texture()
				image = texture.get_data()
				image.flip_y()
				var used_rect := image.get_used_rect()
				image = image.get_rect(used_rect)
				var cel_position : Vector2 = (used_rect.position - origin.position)+viewport_background.scene_position

				ase_ex.add_cel(image, cel_position)
				im+=1
				
				for path in layers[layer]:
					origin.get_node(path).self_modulate = Color.transparent
			
			t += 1.0/fps
			ase_ex.next_frame()
			
	ase_ex.create_file("res://new_test.aseprite")
			
	for sprite in sprites:
		sprite.self_modulate = Color.white
		
	
	canvas.get_parent().need_to_update = true

func _on_ExportButton_pressed():
	export_aseprite()
	

	
