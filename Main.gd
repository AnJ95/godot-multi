tool
extends Node2D


func _on_ButtonSingleplayer_pressed():
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Game.visible = true
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Controls.visible = false

func _on_ButtonCampaign_pressed():
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Game.visible = true
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Controls.visible = false

func _on_ButtonMultiplayer_pressed():
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Game.visible = true
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Controls.visible = false

func _on_ButtonControls_pressed():
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Game.visible = false
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Controls.visible = true
