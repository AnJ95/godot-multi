extends MarginContainer

onready var popup:WindowDialog = get_parent()

func _on_ButtonOK_pressed():
	popup.visible = false

func _on_ButtonUnbind_pressed():
	for player_id in range(Multi.MAX_PLAYERS):
		var player = Multi.player(player_id)
		player.unassign_controller(Multi.__input_map)
