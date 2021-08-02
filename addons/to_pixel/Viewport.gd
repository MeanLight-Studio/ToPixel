tool
extends Viewport

onready var origin := $Origin

func _ready():
	origin.position = size/2.0

func add_scene(scene):
	for child in origin.get_children():
		child.queue_free()
	origin.add_child(scene)

