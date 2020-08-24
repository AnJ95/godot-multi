extends Node2D

func _ready():
	var rand_idx = randi() % get_child_count()
	
	var level = get_child(rand_idx)
	remove_child(level)
	
	for other_level in get_children():
		other_level.queue_free()
	
	level.visible = true
	add_child(level)
