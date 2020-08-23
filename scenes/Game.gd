extends Node

func _ready():
	Multi.start_enforcing_player_num()
	
	for player_id in range(Multi.get_num_assigned_players()):
		$CharacterSpawner.spawn(player_id)

