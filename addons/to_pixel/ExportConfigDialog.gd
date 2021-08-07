tool
extends PopupDialog

export (NodePath) var ui_path

var file_name := ""
var current_ext := ".aseprite"

onready var ui := get_node(ui_path)
onready var select_file_button := $VBoxContainer/HBoxContainer/SelectFileButton
onready var file_name_edit := $VBoxContainer/HBoxContainer/LineEdit
onready var format_option := $VBoxContainer/OptionButton
onready var file_dialog := $FileDialogSave

func _ready():
	select_file_button.icon = get_icon("Folder", "EditorIcons")

func _on_ExportConfigDialog_about_to_show():
	update_config()

func update_config():
	if ui.scene:
		current_ext = ".aseprite" if format_option.selected == 0 else ".png"
		var n := file_name if file_name != "" else ui.scene.name
		file_name_edit.text = ("res://" + n).rsplit(".", true, 1)[0] + current_ext

func _on_OptionButton_item_selected(_index):
	update_config()


func _on_SelectFileButton_pressed():
	file_dialog.filters = ["*"+current_ext]
	file_dialog.popup()


func _on_FileDialogSave_file_selected(path):
	file_name = path
	print(path)
	update_config()


func _on_Button_pressed():
	hide()
