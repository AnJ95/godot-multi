tool
extends GridContainer

const ControlMenu = preload("res://addons/multi/controlsmenu/ControlMenu.tscn")

var created_menu_for_player_ids = []

func _ready():
	add_control_menus()
	
	Multi.connect("num_assigned_players_changed", self, "_on_num_assigned_players_changed")

func _on_num_assigned_players_changed(_num):
	add_control_menus()
	
func add_control_menus():
	for i in range(Multi.MAX_PLAYERS):
		
		var inst:Control
		
		if created_menu_for_player_ids.has(i):
			continue
		
		var player:Player = Multi.player(i)
		if player and player.is_controller_connected():
			inst = ControlMenu.instance()
			inst.init(i)
			created_menu_for_player_ids.append(i)
		else:
			inst = Label.new()
			inst.text = str("Player %d not connected" % (i+1))
			inst.size_flags_horizontal = SIZE_EXPAND_FILL
			inst.size_flags_vertical = SIZE_EXPAND_FILL
			inst.align = HALIGN_CENTER
			inst.valign = VALIGN_CENTER
			
		if get_child_count() > i:
			var prev_child = get_child(i)
			
			add_child_below_node(prev_child, inst)
			
			remove_child(prev_child)
			prev_child.queue_free()
		else:
			add_child(inst)
