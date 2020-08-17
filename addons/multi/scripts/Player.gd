extends Object
class_name Player

var __controller:Controller = null
var __player_id:int = -1

func _init(player_id:int):
	__player_id = player_id
	
func __convert_action(action:String)->String:
	return "player_%d_%s" % [__player_id, action]
	
func set_controller(controller:Controller)->void:
	__controller = controller
	
	for action in InputMap.get_actions():
		if action.begins_with(__convert_action("")):
			for event in InputMap.get_action_list(action):
				event.device = controller.__device_id

func has_controller_assigned():
	return __controller != null

func is_controller_connected()->bool:
	return has_controller_assigned() and __controller.is_controller_connected()

func is_action_pressed(action:String)->bool:			return Input.is_action_pressed(__convert_action(action))
func is_action_just_pressed(action:String)->bool:	return Input.is_action_just_pressed(__convert_action(action))
func is_action_just_released(action:String)->bool:	return Input.is_action_just_released(__convert_action(action))
func get_action_strength(action:String)->float:		return Input.get_action_strength(__convert_action(action))
