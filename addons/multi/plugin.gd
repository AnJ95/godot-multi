tool
extends EditorPlugin

const BASE_PATH = "res://addons/multi/"
const AUTOLOADS_PATH = BASE_PATH + "autoloads/"

const Dock = preload("res://addons/multi/dock/Dock.tscn")
var dock

const autoloads = {
	"Multi":				AUTOLOADS_PATH + "Multi.gd",
}


func _enter_tree():
	for key in autoloads.keys():
		add_autoload_singleton(key, autoloads[key])

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

	remove_control_from_bottom_panel(dock)
	dock.queue_free()

