tool
extends VBoxContainer

export (NodePath) var canvas_viewport_path
onready var canvas_viewport := get_node(canvas_viewport_path)

onready var width_spinbox := $PanelContainer/GridContainer/SpinBoxCanvasWidth
onready var height_spinbox := $PanelContainer/GridContainer/SpinBoxCanvasHeight

func _ready():
	width_spinbox.value = canvas_viewport.size.x
	height_spinbox.value = canvas_viewport.size.y


func _on_SpinBoxCanvasWidth_value_changed(value):
	canvas_viewport.size.x = value


func _on_SpinBoxCanvasHeight_value_changed(value):
	canvas_viewport.size.y = value
