tool
extends Tree

signal sprite_moved
signal layer_moved(layer_names)
signal layer_name_changed(old_name, new_name)

var _item_edited : TreeItem
var _item_edited_name := ""

func get_drag_data(_position):

	var preview = Label.new()
	preview.text = get_selected().get_text(0)
	set_drag_preview(preview)

	return get_selected()


func can_drop_data(_position, data):
	if data is TreeItem:
		set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
	return data is TreeItem


func drop_data(position, item : TreeItem):

	
	var shift = get_drop_section_at_position(position)
	var to_item : TreeItem = get_item_at_position(position)
	var parent_item : TreeItem
	
	parent_item = to_item
	var type : String =  item.get_metadata(0)["type"]
	if type == "layer":
		parent_item = get_root()
	else:
		if parent_item.get_metadata(0)["type"] != "layer" or shift != 0:
			parent_item = to_item.get_parent()
		if parent_item == get_root():
			return
	
	var idx = 0
	var position_item : TreeItem = parent_item.get_children()
	
	# move item
	
	while position_item != null:
		idx +=1
		if position_item == to_item:
			if shift < 0:
				idx -= 1 
			break
		position_item = position_item.get_next()
		
	
	var new_item := create_item(parent_item, idx)
	new_item.set_text(0, item.get_text(0))
	new_item.set_metadata(0, item.get_metadata(0))
	new_item.set_icon(0, item.get_icon(0))
	new_item.set_icon_max_width(0, item.get_icon_max_width(0))
	
	var item_child := item.get_children()
	
	while item_child != null:
		var new_item_child := create_item(new_item)
		new_item_child.set_text(0, item_child.get_text(0))
		new_item_child.set_metadata(0, item_child.get_metadata(0))
		new_item_child.set_icon(0, item_child.get_icon(0))
		new_item_child.set_icon_max_width(0, item_child.get_icon_max_width(0))
		item_child = item_child.get_next()
	
	item.free()
	
	if type == "layer":
		var layer := get_root().get_children()
		var layer_names := []
		while layer != null:
			layer_names.append(layer.get_text(0))
			layer = layer.get_next()
		emit_signal("layer_moved", layer_names)
	else:
		emit_signal("sprite_moved")


func _on_Tree_item_activated():
	var selected_item : TreeItem = get_selected()
	if selected_item:
		_item_edited = selected_item
		_item_edited_name = _item_edited.get_text(0)
		selected_item.set_editable(0,true)
		edit_selected()
		selected_item.set_editable(0,false)


func _on_Tree_item_edited():
	var edited_item : TreeItem = get_selected()
	emit_signal("layer_name_changed", _item_edited_name, edited_item.get_text(0))
