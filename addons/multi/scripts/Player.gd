extends Node


var __controller = null
var __player_id = null

func _init(player_id):
	__player_id = player_id
	
func __convert_action(action:String)->String:
	return "player_" + str(__player_id) + "_" + action
	
func set_controller(controller)->void:
	__controller = controller
	
func is_controller_connected()->bool:
	return __controller != null and __controller.is_controller_connected()

func is_action_pressed(action:String)->bool:			return Input.is_action_pressed(__convert_action(action))
func is_action_just_pressed(action:String)->bool:	return Input.is_action_just_pressed(__convert_action(action))
func is_action_just_released(action:String)->bool:	return Input.is_action_just_released(__convert_action(action))
func get_action_strength(action:String)->float:		return Input.get_action_strength(__convert_action(action))
