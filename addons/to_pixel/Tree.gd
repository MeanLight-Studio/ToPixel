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
	var shift = get_drop_section_at_position(position)
	var to_item : TreeItem = null
	
	to_item = get_item_at_position(position)
	if to_item.get_metadata(0)["type"] != "layer" or shift != 0:
		to_item = get_item_at_position(position).get_parent()
	if to_item == get_root():
		return
		
	var new_item := create_item(to_item)
	new_item.set_text(0, item.get_text(0))
	new_item.set_metadata(0, item.get_metadata(0))
	item.free()
		

func _on_Tree_item_activated():
	var selected_item : TreeItem = get_selected()
	if selected_item:
		selected_item.set_editable(0,true)
		edit_selected()
		selected_item.set_editable(0,false)
