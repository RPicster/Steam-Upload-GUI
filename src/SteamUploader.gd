extends PanelContainer

const ENCRYPT_PW : String		= "STEAMUPLOADGUI"
const SETTINGS_FILE : String	= "/SteamUploadGUI_settings.bin"
const STEAMCMD : String			= "steamcmd.exe"
const GODOT_BAT : String		= "godot_exec.bat"
const BATCH_CONTENT : String	= "@echo off\nSTART cmd {mode} \"\"{path}steamcmd.exe\" {args}\""
const STEAM_GUARD : String		= "cd {path} && {steam_cmd} \"set_steam_guard_code {guard_code}\""
const TEXT_WAIT_CLOSE : String	= "Please close Steam shell when it is done to continue.\nUploading App ID '%s'"
const TEXT_WAIT : String		= "Waiting for Content Builder and Upload.\nUploading App ID '%s'"
const AppGroup : PackedScene	= preload("res://AppGroup.tscn")

var local_dir : String			= ""
var contentbuilder_dir : String = ""
var scripts_path : String		= ""
var builder_path : String		= ""
var steam_apps : Array			= []

var regex_appid : RegEx		= RegEx.new()
var regex_descr : RegEx		= RegEx.new()


func _ready() -> void:
	regex_appid.compile("\"appid\".\"(.*)\"")
	regex_descr.compile("\"desc\".\"(.*)\"")
	
	local_dir = ProjectSettings.globalize_path("res://")
	if local_dir == "":
		local_dir = OS.get_executable_path().get_base_dir()
	else:
		local_dir = local_dir.get_base_dir()
	contentbuilder_dir = local_dir
	
	# Load local Settings saved from last Upload
	var save_pw_file := File.new()
	if save_pw_file.file_exists(local_dir + SETTINGS_FILE):
		save_pw_file.open_encrypted_with_pass(local_dir + SETTINGS_FILE, File.READ, ENCRYPT_PW)
		var settings_json_result : JSONParseResult = JSON.parse(save_pw_file.get_as_text())
		if settings_json_result.result:
			$"%UserNameEdit".text = settings_json_result.result.user
			$"%UserPasswordEdit".text = settings_json_result.result.pw
			contentbuilder_dir = settings_json_result.result.path
			$"%SavePW".pressed = true
	save_pw_file.close()
	
	$"%ContentBuilderPathEdit".text = contentbuilder_dir
	if check_contentbuilder_path():
		generate_apps_from_vdfs()


func clear_apps():
	# Clear old list of Steam apps...
	if not steam_apps.empty():
		for steam_app in steam_apps:
			steam_app.queue_free()
		steam_apps.clear()


func generate_apps_from_vdfs():
	clear_apps()
	scripts_path = contentbuilder_dir + "/scripts/"
	# Get all the files located in the /scripts/ folder
	var dir := Directory.new()
	if dir.dir_exists(scripts_path):
		$"%AppsErrorMessage".hide()
		var files : Array = list_vdf_files_in_directory(scripts_path)
		for file_name in files:
			var file := File.new()
			if not file.file_exists(scripts_path + file_name):
				continue
			file.open(scripts_path + file_name, File.READ)
			var file_content : String = file.get_as_text()
			file_content = file_content.to_lower()
			file.close()
			if file_content.left(10) != "\"appbuild\"":
				# The file is not a "app" vdf, only a depot vdf
				continue
			
			# Create the App Group elements
			var new_app_group : AppGroup = AppGroup.instance()
			new_app_group.setup(get_appid(file_content), get_desc(file_content), file_name)
			$"%AppsToUpload".add_child(new_app_group)
			steam_apps.append(new_app_group)
	else:
		$"%AppsErrorMessage".show()
		


func check_contentbuilder_path() -> bool:
	var dir := Directory.new()
	builder_path = contentbuilder_dir + "/builder/"
	if !dir.dir_exists(builder_path):
		clear_apps()
		$"%AppsErrorMessage".show()
		$"%UploadButton".text = "Builder path not found (\"tools\\ContentBuilder\\builder\\\")!"
		$"%UploadButton".disabled = true
		return false
	else:
		var file := File.new()
		if !file.file_exists(builder_path + STEAMCMD):
			$"%AppsErrorMessage".show()
			$"%UploadButton".text = "steamcmd.exe not found (\"tools\\ContentBuilder\\builder\\steamcmd.exe\")!"
			$"%UploadButton".disabled = true
			return false
		else:
			$"%UploadButton".text = "Upload"
			$"%UploadButton".disabled = false
			return true


func get_appid(_string:String) -> String:
	var s_id_r : RegExMatch = regex_appid.search(_string)
	if s_id_r:
		return s_id_r.get_string(1)
	return "App ID not found!"


func get_desc(_string:String) -> String:
	var s_desc_r : RegExMatch = regex_descr.search(_string)
	if s_desc_r:
		return s_desc_r.get_string(1)
	return "Desc not found!"


func list_vdf_files_in_directory(path:String) -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".vdf"):
			files.append(file)
	
	dir.list_dir_end()
	return files


func _on_UploadButton_pressed() -> void:
	# Save the Settings
	var save_pw_file := File.new()
	save_pw_file.open_encrypted_with_pass(local_dir + SETTINGS_FILE, File.WRITE, ENCRYPT_PW)
	var settings_dict := {"pw": "", "user": $"%UserNameEdit".text, "path" : $"%ContentBuilderPathEdit".text}
	if $"%SavePW".pressed:
		settings_dict.pw = $"%UserPasswordEdit".text
	save_pw_file.store_string(JSON.print(settings_dict))
	save_pw_file.close()
	
	# Create an array of the selected vdfs
	# Update the desc content of the vdfs
	var selected_vdfs : Array = []
	for app in steam_apps:
		if app.is_selected():
			selected_vdfs.append({"file": app.vdf_file_name, "app_id": app.app_id})
			var vdf_file := File.new()
			vdf_file.open(scripts_path + app.vdf_file_name, File.READ)
			var vdf_content : String = vdf_file.get_as_text()
			vdf_file.close()
			var as_lines : PoolStringArray = vdf_content.split("\n")
			for i in as_lines.size():
				if as_lines[i].strip_edges().begins_with("\"desc\""):
					as_lines[i] = as_lines[i].split("\"desc\"")[0] + ("\"desc\" \"%s\"" % app.desc)
					break
			var vdf_write_file := File.new()
			vdf_write_file.open(scripts_path + app.vdf_file_name, File.WRITE)
			vdf_write_file.store_string(as_lines.join("\n"))
			vdf_write_file.close()
	
	# Upload each App from the selected vdfs
	# A batch file is generated for every upload. This is a workaround of the problem
	# That 'blocking' on OS.execute() while showing the shell will lead to an empty
	# shell window as the stdout is consumed.
	for upload in selected_vdfs:
		var bat_file := File.new()
		var vdf_path = "\"../scripts/%s\"" % upload.file
		var args : PoolStringArray = ["+login", $"%UserNameEdit".text, $"%UserPasswordEdit".text, "+run_app_build", vdf_path, "+quit"]
		var shell_mode : String = "/k" if $"%KeepShellOpen".pressed else "/c"
		# Open the Popup informing the user that this is paused until the shells are closed
		$"%SteamUploadingPopup".popup()
		$"%SteamUploadLabel".text = TEXT_WAIT_CLOSE % upload.app_id if $"%KeepShellOpen".pressed else TEXT_WAIT % upload.app_id
		yield(get_tree(), "idle_frame")
		bat_file.open(local_dir + "godot_exec.bat", File.WRITE)
		bat_file.store_string(BATCH_CONTENT.format({"mode": shell_mode, "path": builder_path, "args": args.join(" ")}))
		bat_file.close()
		OS.execute(local_dir + "godot_exec.bat", [], true, [])
	
	yield(get_tree(), "idle_frame")
	var remove_bat := Directory.new()
	remove_bat.remove(local_dir + "godot_exec.bat")
	$"%SteamUploadingPopup".hide()


func _on_SetSteamGuardButton_pressed():
	$"%SteamGuardPopup".popup_centered(Vector2.ONE)
	$"%SteamGuardCodeEdit".grab_focus()


func _on_SendSteamGuardButton_pressed():
	var cmd_arg = STEAM_GUARD.format({"path": builder_path, "steam_cmd": STEAMCMD, "guard_code": $"%SteamGuardCodeEdit".text, })
	OS.execute("cmd", ["/c", cmd_arg], false, [], true, true)
	$"%SteamGuardPopup".hide()


func _on_SteamGuardCodeEdit_text_changed(new_text:String) -> void:
	$"%SendSteamGuardButton".disabled = new_text.length() < 5


func _on_ContentBuilderPathEdit_text_entered(new_text:String) -> void:
	contentbuilder_dir = new_text.trim_suffix("\\")
	if check_contentbuilder_path():
		generate_apps_from_vdfs()


func _on_OpenDirButton_pressed():
	$PopupLayer/FileDialog.popup_centered()


func _on_FileDialog_dir_selected(dir):
	_on_ContentBuilderPathEdit_text_entered(dir)
	$"%ContentBuilderPathEdit".text = contentbuilder_dir


func _on_RefreshButton_pressed():
	generate_apps_from_vdfs()


func _on_popup_about_to_show():
	$PopupLayer/FileDialogBG.show()


func _on_popup_hide():
	$PopupLayer/FileDialogBG.hide()


func _on_GitHubLinkButton_pressed():
	OS.shell_open("https://github.com/RPicster/Steam-Upload-GUI")


func _on_CoffeeLinkButton_pressed():
	OS.shell_open("https://www.buymeacoffee.com/raffa")
