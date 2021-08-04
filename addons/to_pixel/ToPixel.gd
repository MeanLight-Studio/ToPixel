tool
extends Control

var fps := 12.0

onready var canvas := $HBoxContainer/ViewportBackground/TextureRect
onready var ui := $HBoxContainer/UI
onready var texture_in_viewport := $HBoxContainer/ViewportBackground/Viewport/TextureRect
onready var viewport_background := $HBoxContainer/ViewportBackground
onready var layers_container := $Layers

func export_aseprite():
	var ase_ex := AsepriteExporter.new()
	
	ase_ex.frame_duration_ms = 1.0/fps*1000
	
	ase_ex.set_canvas_size_px(ui.width_spinbox.value, ui.height_spinbox.value)
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
	
			
	VisualServer.force_draw(true)
	var image : Image
	var tic := OS.get_ticks_msec()
	for animation_name in animations:
		set_animation(animation_name)
		var animation : Animation = animation_player.get_animation(animation_name)
		stop_animations()
		var t := 0.0
		while t <= animation.length:
			sync_animations(t)
#			canvas.get_parent().need_to_update = true
			yield(VisualServer,"frame_post_draw")
			
			for layer in layers:
					
				var viewport : Viewport = layers_container.get_layer(layer)
				var origin : Position2D = viewport.origin
				var texture : Texture = viewport.get_texture()
				image = texture.get_data()
				image.flip_y()
				var used_rect := image.get_used_rect()
				image = image.get_rect(used_rect)
				var cel_position : Vector2 = (used_rect.position - origin.position)+viewport_background.scene_position

				ase_ex.add_cel(image, cel_position)

			
			t += 1.0/fps
			ase_ex.next_frame()
			
	ase_ex.create_file("res://new_test.aseprite")
			
	print(OS.get_ticks_msec()-tic)
	
	canvas.get_parent().need_to_update = true

func _on_ExportButton_pressed():
	export_aseprite()
	

func set_animation(animation_name : String):
	for layer in layers_container.get_children():
		ui.get_current_animation_player(layer).current_animation = animation_name
		
func stop_animations():
	for layer in layers_container.get_children():
		ui.get_current_animation_player(layer).stop()
		
func sync_animations(t : float):
	for layer in layers_container.get_children():
		ui.get_current_animation_player(layer).seek(t,true)
