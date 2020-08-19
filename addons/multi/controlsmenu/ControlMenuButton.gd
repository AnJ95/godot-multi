tool
extends HBoxContainer

#############################################################
# SIGNALS
signal control_changed()

#############################################################
# NODES
onready var button = $Button

#############################################################
# CONSTS

#############################################################
# CUSTOMIZATION



#############################################################
# STATE
var awaiting = false

var player_id:int = 0
var action:String
var event_i:int

var event:InputEvent

var player:Player

#############################################################
# LIFECYCLE
func init(player_id, action, event_i):
	self.player_id = player_id
	self.action = action
	self.event_i = event_i
	
	player = Multi.player(player_id)
	
	var ev_list = player.get_action_list(action)
	event = ev_list[event_i] if ev_list.size() > event_i else null
	
	# gotta do this before ready
	$Button.player_id = player_id
	$ButtonRemove.player_id = player_id
	
func _ready():
	button.text = get_display_caption()

#############################################################
# AWAITING CONDITION
func start_awaiting():
	for other in get_others():
		other.end_awaiting()
	button.pressed = true
	awaiting = true
	button.text = "<Enter Key>"
	
func end_awaiting():
	awaiting = false
	button.pressed = false
	button.text = get_display_caption()

#############################################################
# GETTERS & SETTERS
func set_event(ev:InputEvent):
	
	if ev is InputEventJoypadMotion:
		ev.axis_value = sign(ev.axis_value)
		
	event = ev
	
	# Unassign all other that have the same key
	if ev != null:
		for other in get_others():
			if events_equal(event, other.event):
				other.set_event(null)
	
	# Update button text
	button.text = get_display_caption()
	

func get_display_caption():
	if event:
		return Multi.get_pretty_string(event)
	return "<Unassigned>"

func get_others():
	var others = []
	for other in get_tree().get_nodes_in_group("ControlMenuButton"):
		if other != self and other.player_id == player_id:
			others.append(other)
	return others

func events_equal(a:InputEvent, b:InputEvent):
	if a is InputEventMouseButton and b is InputEventMouseButton:
		return a.button_index == b.button_index
	if a is InputEventKey and b is InputEventKey:
		return a.scancode == b.scancode
	if a is InputEventJoypadButton and b is InputEventJoypadButton:
		return a.button_index == b.button_index
	if a is InputEventJoypadMotion and b is InputEventJoypadMotion:
		return a.axis == b.axis and sign(a.axis_value) == sign(b.axis_value)
	
#############################################################
# CALLBACKS

func _on_Button_toggled(button_pressed):
	if !awaiting and button_pressed:
		start_awaiting()

func _input(event:InputEvent):
	if awaiting:
		if event and player.is_event_from_this_player(event):
			accept_event()
			set_event(event)
			emit_signal("control_changed")
			end_awaiting()
			return true
					
func grab_focus():
	button.is_focused = true
