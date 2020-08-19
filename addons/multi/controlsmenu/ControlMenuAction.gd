tool
extends Control

const ControlMenuButton = preload("ControlMenuButton.tscn")

onready var label = $VBoxContainer/HBoxContainer/Label
onready var btn_root = $VBoxContainer/ControlMenuButtons

var player_id:int = 0
var action:String

var player:Player

func init(player_id:int, action:String):
	self.player_id = player_id
	self.action = action
	
	player = Multi.player(player_id)
	
func _ready():
	# Use pretty name if given, else replace _ with spaces and capitlize first letter
	if Multi.PRETTY_ACTION_NAMES.has(action):
		label.text = Multi.PRETTY_ACTION_NAMES[action]
	else:
		label.text = (action.substr(0, 1).to_upper() + action.substr(1, -1).to_lower()).replace("_", " ")
	
	# Add button for every event
	for i in range(player.get_action_list(action).size()):
		add_button()

func add_button():
	var btn_inst = ControlMenuButton.instance()
	btn_inst.init(player_id, action, btn_root.get_child_count())
	btn_inst.get_node("ButtonRemove").connect("pressed", self, "_on_ButtonRemove_pressed", [btn_inst])
	btn_inst.connect("control_changed", self, "_on_control_changed")
	btn_root.add_child(btn_inst)
	return btn_inst

func _on_control_changed():
	InputMap.action_erase_events(player.__convert_action(action))
	for btn in btn_root.get_children():
		if btn.event:
			InputMap.action_add_event(player.__convert_action(action), btn.event)
	
func _on_ButtonAdd_pressed():
	add_button().start_awaiting()
	
func _on_ButtonRemove_pressed(btn):
	# remove button
	btn_root.remove_child(btn)
	btn.queue_free()
	
	# update InputMap
	_on_control_changed()
	
	# reassign index to other buttons
	for o in range(btn_root.get_child_count()):
		btn_root.get_child(o).event_i = o

func grab_focus():
	if btn_root.get_child_count() > 0:
		btn_root.get_child(0).grab_focus()
