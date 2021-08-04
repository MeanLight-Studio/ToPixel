tool
extends Viewport

var layer_name := ""
var _sprites_path := []
var _animation_players := []

onready var origin := $Origin

func _ready():
	origin.position = size/2.0

func add_scene(scene):
	for child in origin.get_children():
		child.queue_free()
		yield(child, "tree_exited")
	origin.add_child(scene)
	
func get_sprite_paths():
	_sprites_path = []
	_get_sprites_path(self)
	return _sprites_path
	
func get_animation_players():
	_animation_players = []
	_get_animation_players(self)
	return _animation_players

func _get_sprites_path(node):
	if node is Sprite or node is Polygon2D:
		_sprites_path.append(origin.get_path_to(node))
	for child in node.get_children():
		_get_sprites_path(child)
		
func _get_animation_players(node):
	if node is AnimationPlayer:
		_animation_players.append(node)
	for child in node.get_children():
		_get_animation_players(child)

func set_children_visible(children_info : Dictionary):
	for path in children_info:
		origin.get_node(path).self_modulate = Color.white if children_info[path] else Color.transparent
