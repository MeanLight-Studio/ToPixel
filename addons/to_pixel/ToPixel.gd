tool
extends Control

var fps := 12.0
var file_name := "test.aseprite"

onready var canvas := $HBoxContainer/ViewportBackground/TextureRect
onready var ui := $HBoxContainer/UI
onready var canvas_viewport := $HBoxContainer/ViewportBackground/Viewport
onready var texture_in_viewport := $HBoxContainer/ViewportBackground/Viewport/TextureRect
onready var viewport_background := $HBoxContainer/ViewportBackground
onready var layers_container := $Layers
onready var config_dialog := $ExportConfigDialog
onready var progress_bar : ProgressBar = viewport_background.get_node("ProgressBar")
onready var progress_label : Label = progress_bar.get_node("Label")

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
	progress_bar.visible = true
	for animation_name in animations:
		progress_label.text = "Exporting '" + animation_name + "' animation..."
		set_animation(animation_name)
		var animation : Animation = animation_player.get_animation(animation_name)
		stop_animations()
		var t := 0.0
		while t <= animation.length:
			progress_bar.value = 100.0*t/animation.length
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
			
	ase_ex.create_file(file_name)
			
	progress_bar.visible = false
	
	canvas.get_parent().need_to_update = true


func export_spritesheet():
	var frame_size := Vector2(ui.width_spinbox.value, ui.height_spinbox.value)

	var animations : Array = ui.get_animations(true)
	var layers : Dictionary = ui.get_layers()
		
	# Will export all layers together, so only need one layer and make everything visible
	var viewport : Viewport = layers_container.get_layer(layers.keys()[0])
	var animation_player : AnimationPlayer = ui.get_current_animation_player(viewport)
	stop_animations()
	# Animations will be in separate rows
	# Height of the spritesheet is frame height * animation count
	# Width of the spritesheet is frame width * frame count of the longest animation
	var max_frame_count := 0
	for animation_name in animations:
		var animation := animation_player.get_animation(animation_name)
		if animation.length * fps > max_frame_count:
			max_frame_count = animation.length*fps
			
	var spritesheet := Image.new()
	spritesheet.create(max_frame_count*frame_size.x, animations.size()*frame_size.y, false, Image.FORMAT_RGBA8)
	spritesheet.fill(Color.transparent)
	# Make every sprite visible regardless the layer
	viewport.set_all_children_visibility(true)
	
	var i := 0
	for animation_name in animations:
		animation_player.current_animation = animation_name
		var t := 0.0
		var j := 0
		while t <= animation_player.current_animation_length:
			animation_player.seek(t)
			yield(VisualServer,"frame_post_draw")
			var image : Image = canvas_viewport.get_texture().get_data()
			spritesheet.blend_rect(image, Rect2(Vector2.ZERO, image.get_size()), Vector2(j*frame_size.x, i*frame_size.y))
			t += 1.0/fps
			j += 1
		i += 1
		
	spritesheet.save_png("res://test.png")
	
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
	
func export_file():
	match config_dialog.current_ext:
		".aseprite":
			export_aseprite()
		".png":
			export_spritesheet()
			
	file_name = config_dialog.file_name_edit.text
