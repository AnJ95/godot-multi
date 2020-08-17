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
		"script" : load(CUSTOM_TYPES_PATH + "PlayerConstraintButton.gd"),
		"icon": get_editor_interface().get_base_control().get_icon("Button", "EditorIcons")
	},
	"PlayerStatus": {
		"base" : "Control",
		"script" : load(CUSTOM_TYPES_PATH + "PlayerStatus.gd"),
		"icon": get_editor_interface().get_base_control().get_icon("Control", "EditorIcons")
	},
	"MultiPlayerStatus": {
		"base" : "HBoxContainer",
		"script" : load(CUSTOM_TYPES_PATH + "MultiPlayerStatus.gd"),
		"icon": get_editor_interface().get_base_control().get_icon("HBoxContainer", "EditorIcons")
	},
}


func _enter_tree():
	for key in autoloads.keys():
		add_autoload_singleton(key, autoloads[key])
	for key in custom_types.keys():
		var type = custom_types[key]
		add_custom_type(key, type.base, type.script, type.icon)

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

