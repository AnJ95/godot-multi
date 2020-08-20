tool
extends CanvasLayer

func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/ButtonControls.grab_focus()
	$MultiplayerBindPopup.popup_centered()

func _on_ButtonSingleplayer_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")

func _on_ButtonCampaign_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")

func _on_ButtonMultiplayer_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")

func _on_ButtonControls_pressed():
	get_tree().change_scene("res://scenes/Controls.tscn")

func _on_ButtonControlsSimple_pressed():
	get_tree().change_scene("res://scenes/ControlsSimple.tscn")
