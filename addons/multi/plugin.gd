tool
extends EditorPlugin

const BASE_PATH = "res://addons/multi/"
const AUTOLOADS_PATH = BASE_PATH + "autoloads/"
const CUSTOM_TYPES_PATH = BASE_PATH + "components/"

const Dock = preload("res://addons/multi/dock/Dock.tscn")
var dock

const autoloads = {
	"Multi": AUTOLOADS_PATH + "Multi.gd",
}

var custom_types = {
	"PlayerConstraintButton": {
		"base" : "Button",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerConstraintButton.gd")
	},
	"PlayerStatus": {
		"base" : "Control",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerStatus.gd")
	},
	"MultiPlayerStatus": {
		"base" : "Button",
		"script" : load(CUSTOM_TYPES_PATH + "MultiPlayerStatus.gd")
	},
	"MultiPlayerControlMenu": {
		"base" : "GridContainer",
		"script" : load(CUSTOM_TYPES_PATH + "MultiPlayerControlMenu.gd")
	},
	"PlayerFocusButton": {
		"base" : "Button",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerFocusControl.gd")
	},
	"PlayerFocusCheckBox": {
		"base" : "CheckBox",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerFocusControl.gd")
	},
	"PlayerFocusCheckButton": {
		"base" : "CheckButton",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerFocusControl.gd")
	},
	"PlayerFocusOptionButton": {
		"base" : "OptionButton",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerFocusControl.gd")
	},
	"MultiPlayerBindPopup": {
		"base" : "WindowDialog",
		"script" : load(CUSTOM_TYPES_PATH + "MultiPlayerBindPopup.gd")
	}
}


func _enter_tree():
	
	for key in autoloads.keys():
		add_autoload_singleton(key, autoloads[key])
		
	var icon:Texture = preload("res://addons/multi/assets/logo/logo16.png")
	
	for key in custom_types.keys():
		var type = custom_types[key]
		add_custom_type(key, type.base, type.script, icon)

	# Add the loaded scene to the docks.
	dock = create_dock()
	add_control_to_bottom_panel(dock, "Multi")


func create_dock():
	var dock = Dock.instance()
	dock.plugin = self
	dock.ei = get_editor_interface()
	return dock


func _exit_tree():
	for key in autoloads.keys():
		remove_autoload_singleton(key)
	for key in custom_types.keys():
		remove_custom_type(key)

	remove_control_from_bottom_panel(dock)
	dock.queue_free()

