extends Control

const MIN_SPAWN_DST = 60
const Character = preload("res://game/Character.tscn")

func spawn(player_id:int):
	var inst = Character.instance()
	inst.player_id = player_id
	inst.color = get_player_color(player_id)
	inst.connect("respawn_character", self, "respawn")
	add_child(inst)
	inst.global_position = get_valid_spawn_point()

func respawn(character):
	character.global_position = get_valid_spawn_point()
	
func get_valid_spawn_point()->Vector2:
	var spawn = null
	var iterations = 0
	while !spawn:
		var r = get_global_rect()
		spawn = Vector2(rand_range(r.position.x, r.position.x + r.size.x), 
			rand_range(r.position.y, r.position.y + r.size.y))
		
		if iterations < 100:
			for child in get_children():
				if spawn.distance_to(child.global_position) < MIN_SPAWN_DST:
					spawn = null
					break
		iterations += 1
	return spawn
	
func get_player_color(player_id:int)->Color:
	var hue = player_id / float(Multi.get_num_assigned_players())
	return Color().from_hsv(hue, 0.7, 0.6, 1)
	

