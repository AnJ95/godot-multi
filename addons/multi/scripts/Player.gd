extends Node


var __controller = null
var __player_id = null

func _init(player_id):
	__player_id = player_id
	
func set_controller(controller):
	__controller = controller
	
func is_controller_connected():
	return __controller != null and __controller.is_controller_connected()
