extends MarginContainer

onready var popup:WindowDialog = get_parent()
onready var btn_ok = $VBoxContainer/HBoxContainer/ButtonOK
func _ready():
	popup.connect("about_to_show", self, "_on_about_to_show")
	popup.connect("popup_hide", self, "_on_popup_hide")
	Multi.connect("num_assigned_players_changed", self, "_on_num_assigned_players_changed")
	_on_num_assigned_players_changed(-1)

func _on_about_to_show():
	btn_ok.call_deferred("grab_focus")
	get_tree().paused = true

func _on_popup_hide():
	get_tree().paused = false

func _on_num_assigned_players_changed(_num):
	if Multi.is_enforcing_player_num():
		btn_ok.disabled = !Multi.is_enforcement_satisfied()

func _on_ButtonOK_pressed():
	popup.visible = false
	
func _on_ButtonUnbind_pressed():
	for player_id in range(Multi.MAX_PLAYERS):
		var player = Multi.player(player_id)
		player.unassign_controller(Multi.__input_map)
