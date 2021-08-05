tool
extends VBoxContainer

export (NodePath) var canvas_viewport_path
export (NodePath) var layers_path
export (NodePath) var viewport_background_path

var sprites := []
var animation_players := []
var layers = 0

onready var canvas_viewport := get_node(canvas_viewport_path)
onready var layers_container := get_node(layers_path)
onready var viewport_background := get_node(viewport_background_path)

onready var width_spinbox := $PanelContainer/GridContainer/SpinBoxCanvasWidth
onready var height_spinbox := $PanelContainer/GridContainer/SpinBoxCanvasHeight
onready var player_options := $PanelContainer2/VBoxContainer/OptionButton
onready var player_animations_container := $PanelContainer2/VBoxContainer/AnimationsContainer
onready var sprites_tree := $PanelContainer3/Tree
onready var animations_options := $PanelContainer2/VBoxContainer/VBoxContainer/AnimationOptionButton
onready var export_config_button := $HBoxContainer2/ConfigButton
onready var import_file_dialog := $"../../FileDialog"

func _ready():
	width_spinbox.value = canvas_viewport.size.x
	height_spinbox.value = canvas_viewport.size.y
	export_config_button.icon = get_icon("Edit", "EditorIcons")

func _process(delta):
	if layers_container == null or layers_container.get_child_count() == 0:
		return
	var animation_player := get_current_animation_player()
	if animation_player:
		viewport_background.need_to_update = animation_player.is_playing()
	
func _on_SpinBoxCanvasWidth_value_changed(value):
	canvas_viewport.size.x = value


func _on_SpinBoxCanvasHeight_value_changed(value):
	canvas_viewport.size.y = value

func get_animation_players(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			get_animation_players(child)
		elif child is AnimationPlayer:
			animation_players.append(child)

func get_sprites(node):
	if node is Sprite or node is Polygon2D:
		sprites.append(node)
	elif "self_modulate" in node:
		node.self_modulate = Color.transparent
	for child in node.get_children():
		get_sprites(child)
		

func load_scene(path : String):
	var scene = load(path).instance()
	var viewport := preload("res://addons/to_pixel/Viewport.tscn").instance()
	
	for l in layers_container.get_children():
		l.queue_free()
		yield(l,"tree_exited")
	
	layers_container.add_child(viewport)
	var origin = viewport.origin
	viewport.layer_name = "Layer 1"
	
	viewport.add_scene(scene)
	sprites = []
	get_sprites(scene)
	sprites_tree.clear()
	var root : TreeItem = sprites_tree.create_item()
	root.set_text(0, "Root")
	
	var layer_1 : TreeItem = sprites_tree.create_item(root)
	layers = 1
	layer_1.set_text(0, "Layer 1")
	layer_1.set_metadata(0, {"type" : "layer"})
	for sprite in sprites:
		var child : TreeItem = sprites_tree.create_item(layer_1)
		child.set_text(0, sprite.name)
		child.set_metadata(0, {"type" : "texture", "path" : origin.get_path_to(sprite)})
		child.set_icon(0, sprite.texture)
		child.set_icon_max_width(0,24)
	animation_players = []
	get_animation_players(scene)
	for player in animation_players:
		player_options.add_item(player.name)
		player.connect("animation_finished", self, "_on_animation_finished")
		
	_on_OptionButton_item_selected(0)
	yield(VisualServer,"frame_post_draw")
	viewport_background.need_to_update = true
	
func _on_Button_pressed():
	import_file_dialog.popup()

func _on_OptionButton_item_selected(index):
	var selected_player = animation_players[index]
			
	if not selected_player:
		return
		
	animations_options.clear()
	animations_options.add_item("None")
	
	for child in player_animations_container.get_children():
		child.queue_free()
	
	for animation in selected_player.get_animation_list():
		var checkbox := CheckBox.new()
		checkbox.text = animation
		checkbox.pressed = true
		player_animations_container.add_child(checkbox)
		animations_options.add_item(animation)

func get_current_animation_player(layer = null) -> AnimationPlayer:
	if layer == null:
		layer = layers_container.get_child(0)
	var selected_player : AnimationPlayer = null
	for player in layer.get_animation_players():
		if player_options.text == player.name:
			selected_player = player
			break
	return selected_player

func _on_AnimationOptionButton_item_selected(index):
	for layer in layers_container.get_children():
		var animation_player := get_current_animation_player(layer)
		if index == 0:
			animation_player.stop()
		else:
			animation_player.play(animations_options.text)

func _on_animation_finished(animation):
	animations_options.select(0)


func _on_ButtonAddLayer_pressed():
	if sprites.size() == 0:
		return
		
	layers += 1
	var new_layer : TreeItem = sprites_tree.create_item(sprites_tree.get_root())
	new_layer.set_text(0, "Layer "+str(layers))
	new_layer.set_metadata(0, {"type" : "layer"})
	
	var viewport := layers_container.get_child(0).duplicate()
	layers_container.add_child(viewport)
	viewport.layer_name = "Layer "+str(layers)
	
	update_layers_children_visibility()

func get_animations( only_checked := false) -> Array:
	var animations := []
	for animation in player_animations_container.get_children():
		if animation.is_pressed() or !only_checked:
			animations.append(animation.text)
	return animations

func get_layers() -> Dictionary:
	var layers := {}
	# TODO: simplify this, i thought i needed to invert the layers
	var layers_array := []
	
	var layer : TreeItem = sprites_tree.get_root().get_children()
	while layer != null:
		var sprites := []
		var layer_child : TreeItem = layer.get_children()
		while layer_child != null:
			sprites.append(layer_child.get_metadata(0)["path"])
			layer_child = layer_child.get_next()
		layers[layer.get_text(0)] = sprites
		layers_array.append(layer.get_text(0))
		layer = layer.get_next()
		
#	layers_array.invert()
	var return_layers := {}
	for layer_name in layers_array:
		return_layers[layer_name] = layers[layer_name]
	
	return return_layers


func _on_FileDialog_file_selected(path):
	load_scene(path)

func update_layers_children_visibility():
	var layer : TreeItem = sprites_tree.get_root().get_children()
	var all_layeres_info := {}
	while layer != null:
		var layer_name : String = layer.get_text(0)
		var layer_viewport : Viewport = layers_container.get_layer(layer_name)
		var sprites_in_layer : Array = layer_viewport.get_sprite_paths()
		
		
		var layer_info := {}
		
		for sprite_path in sprites_in_layer:
			layer_info[sprite_path] = false
			var sprite : TreeItem = layer.get_children()
			while sprite != null:
				var sprite_text : String = sprite.get_metadata(0)["path"]
				if sprite_text == sprite_path:
					layer_info[sprite_path] = true
					break
				sprite = sprite.get_next()
				
		all_layeres_info[layer_name] = layer_info
		layer = layer.get_next()
	
	for l in all_layeres_info:
		layers_container.get_layer(l).set_children_visible(all_layeres_info[l])
	
	sync_animation_players()

func sync_animation_players():
	for layer in layers_container.get_children():
		for player in layer.get_animation_players():
			if animations_options.selected != 0:
				player.current_animation = animations_options.text
				player.seek(0, true)
