extends MarginContainer

onready var popup:WindowDialog = get_parent()

func _ready():
	popup.connect("about_to_show", self, "_on_about_to_show")

func _on_about_to_show():
	$VBoxContainer/HBoxContainer/ButtonOK.call_deferred("grab_focus")

func _on_ButtonOK_pressed():
	popup.visible = false
	
func _on_ButtonUnbind_pressed():
	for player_id in range(Multi.MAX_PLAYERS):
		var player = Multi.player(player_id)
		player.unassign_controller(Multi.__input_map)
