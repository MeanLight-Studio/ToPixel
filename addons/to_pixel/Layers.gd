extends Control


func get_layer(name : String) -> Viewport:
	var layer : Viewport
	for l in get_children():
		if l.layer_name == name:
			layer = l
			break
	return layer

func change_layer_name(old_name : String, new_name : String):
	var layer = get_layer(old_name)
	layer.layer_name = new_name

func reorder_layers(layers_names):
	var layers := {}
	for viewport in get_children():
		layers[viewport.layer_name] = viewport
		
	for i in get_children():
		remove_child(i)
		
	for layer_name in layers_names:
		add_child(layers[layer_name])
