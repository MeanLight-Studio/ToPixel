extends Control

var fps := 12.0

onready var canvas := $HBoxContainer/ViewportBackground/TextureRect
onready var ui := $HBoxContainer/UI
onready var origin := $Viewport/Origin

func export_aseprite():
	var ase_ex := AsepriteExporter.new()
	ase_ex.set_canvas_size_px(canvas.rect_size.x, canvas.rect_size.y)
	var animations : Array = ui.get_animations(true)
	var layers : Dictionary = ui.get_layers()
	var animation_player : AnimationPlayer = ui.get_current_animation_player()
	
	ase_ex.define_layers(layers.keys())
	
	animation_player.stop()
	
	# Get sprite array
	
	var sprites := []
	
	for layer in layers:
		for path in layers[layer]:
			sprites.append(origin.get_node(path))
			
	print(sprites)
	
	for i in animations:
		pass

func _on_ExportButton_pressed():
	export_aseprite()
