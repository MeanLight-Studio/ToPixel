tool
extends Tree


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
	if item.get_metadata(0)["type"] == "layer":
		return
	
	var shift = get_drop_section_at_position(position)
	var to_item : TreeItem = get_item_at_position(position)
	var parent_item : TreeItem
	
	parent_item = to_item
	if parent_item.get_metadata(0)["type"] != "layer" or shift != 0:
		parent_item = to_item.get_parent()
	if parent_item == get_root():
		return
	
	var idx = 0
	var position_item : TreeItem = parent_item.get_children()
	
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
	item.free()
	

		

func _on_Tree_item_activated():
	print("doble")
	var selected_item : TreeItem = get_selected()
	if selected_item:
		selected_item.set_editable(0,true)
		edit_selected()
		selected_item.set_editable(0,false)

