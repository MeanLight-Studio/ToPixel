tool
extends VBoxContainer

export (NodePath) var canvas_viewport_path
export (NodePath) var viewport_path
export (NodePath) var viewport_background_path

var sprites := []
var animation_players := []
var layers = 0

onready var canvas_viewport := get_node(canvas_viewport_path)
onready var viewport := get_node(viewport_path)
onready var viewport_background := get_node(viewport_background_path)
onready var origin := viewport.get_node("Origin")

onready var width_spinbox := $PanelContainer/GridContainer/SpinBoxCanvasWidth
onready var height_spinbox := $PanelContainer/GridContainer/SpinBoxCanvasHeight
onready var player_options := $PanelContainer2/VBoxContainer/OptionButton
onready var player_animations_container := $PanelContainer2/VBoxContainer/AnimationsContainer
onready var sprites_tree := $PanelContainer3/Tree
onready var animations_options := $PanelContainer2/VBoxContainer/VBoxContainer/AnimationOptionButton
onready var export_config_button := $HBoxContainer2/ConfigButton


func _ready():
	width_spinbox.value = canvas_viewport.size.x
	height_spinbox.value = canvas_viewport.size.y
	export_config_button.icon = get_icon("Edit", "EditorIcons")

func _process(delta):
	var animation_player := get_current_animation_player()
	if animation_player:
		viewport_background.need_to_update = get_current_animation_player().is_playing()
	
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
	for child in node.get_children():
		get_sprites(child)


func _on_Button_pressed():
	var scene := preload("res://Sprite.tscn").instance()
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

func get_current_animation_player() -> AnimationPlayer:
	var selected_player : AnimationPlayer = null
	for player in animation_players:
		if player_options.text == player.name:
			selected_player = player
			break
	return selected_player

func _on_AnimationOptionButton_item_selected(index):
	var animation_player := get_current_animation_player()
	if index == 0:
		animation_player.stop()
	get_current_animation_player().play(animations_options.text)

func _on_animation_finished(animation):
	animations_options.select(0)


func _on_ButtonAddLayer_pressed():
	if sprites.size() == 0:
		return
	layers += 1
	var new_layer : TreeItem = sprites_tree.create_item(sprites_tree.get_root())
	new_layer.set_text(0, "Layer "+str(layers))
	new_layer.set_metadata(0, {"type" : "layer"})
