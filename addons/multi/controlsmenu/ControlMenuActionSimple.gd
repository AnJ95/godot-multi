tool
extends "ControlMenuAction.gd"


func init(player_id:int, action:String):
	self.player_id = player_id
	self.action = action
	
	label = $HBoxContainer/Label
	btn_root = $HBoxContainer/HBoxContainer

	player = Multi.player(player_id)
	
func add_all_buttons():
	add_button(false)

func _on_control_changed():
	
	# get all current events for this action
	var input_map_save = []
	var conv_action = player.__convert_action(action)
	for event in InputMap.get_action_list(conv_action):
		input_map_save.append(event)
	
	# Replace (or remove) first event in list
	var btn_event = btn_root.get_child(0).event
	if btn_event:
		input_map_save[0] = btn_event
	else:
		input_map_save.remove(0)
	
	# Remove previous events and add altered list
	InputMap.action_erase_events(conv_action)
	for event in input_map_save:
		InputMap.action_add_event(conv_action, event)
	
	
