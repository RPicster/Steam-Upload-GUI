extends PanelContainer
class_name AppGroup

const CHECK_BOX_TEXT : String = "App ID: %s - %s"

var app_id := "" setget set_app_id
var vdf_file_name := "" setget set_vdf_file_name
var desc := "" setget set_desc, get_desc


func setup(_app_id:String, _desc:String, _vdf_file_name:String) -> void:
	set_app_id(_app_id)
	set_desc(_desc)
	set_vdf_file_name(_vdf_file_name)


func set_app_id(_app_id:String) -> void:
	app_id = _app_id
	$HBox/CheckBox.text = CHECK_BOX_TEXT % [app_id, vdf_file_name]


func set_vdf_file_name(_vdf_file_name:String) -> void:
	vdf_file_name = _vdf_file_name
	$HBox/CheckBox.text = CHECK_BOX_TEXT % [app_id, vdf_file_name]


func set_desc(_desc:String) -> void:
	desc = _desc
	$HBox/DescEdit.text = desc


func get_desc() -> String:
	return $HBox/DescEdit.text


func is_selected() -> bool:
	return $HBox/CheckBox.pressed
