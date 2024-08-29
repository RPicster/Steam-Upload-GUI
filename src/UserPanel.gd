extends PanelContainer

signal delete_user
signal save_password

var username : String
var save_pw := true

func _ready():
	$HBoxContainer/Label.text = username
	$HBoxContainer/SavePwdCheckBox.pressed = save_pw


func _on_DeleteButton_pressed():
	emit_signal("delete_user")


func _on_SavePwdCheckBox_pressed():
	emit_signal("save_password", $HBoxContainer/SavePwdCheckBox.pressed)
