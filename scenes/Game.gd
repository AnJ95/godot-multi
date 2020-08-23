extends Node

var num_players

func _ready():
	Multi.start_enforcing_player_num()
	num_players = Multi.get_num_assigned_players()
	
	var char_health = $UI/MarginContainer/VBoxContainer/HBoxContainer2/CharacterHealth
	for player_id in range(num_players):
		var character = $CharacterSpawner.spawn(player_id)
		characters_still_alive.append(character)
		
		var label = Label.new()
		label.modulate = character.color
		char_health.add_child(label)
		
		character.connect("health_changed", self, "_on_health_changed", [label])
		character.connect("lost", self, "_on_character_lost")
		
		_on_health_changed(character.health, label)

var characters_still_alive = []
var characters_lost = []
func _on_character_lost(character):
	characters_still_alive.erase(character)
	
	if characters_still_alive.size() == 1:
		characters_still_alive[0].win()
	
func _on_health_changed(health, label):
	label.text = str(health)
