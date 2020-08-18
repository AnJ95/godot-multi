extends Button

export var player_id = 0
export var is_initially_focused = false

onready var player = Multi.player(player_id)

var action_to_neighbour_map = {
	"ui_left" : "find_focus_left",
	"ui_right" : "find_focus_right",
	"ui_up" : "find_focus_top",
	"ui_down" : "find_focus_bottom",
	"ui_focus_next" : "find_focus_next",
	"ui_focus_previous" : "find_focus_prev"
}


onready var is_focused:bool setget _set_is_focused

onready var focus_node = $Focus
onready var style_empty = focus_node.get_stylebox("Panel")
onready var style_focus = get_stylebox("focus")

func _ready():
	_set_is_focused(is_initially_focused)
	
func _process(_delta):
	# only do this when focussed
	if !is_focused:
		return

	for action in action_to_neighbour_map.keys():
		if player.is_action_just_pressed(action):
			if player_id == 0:
				print(player.__convert_action(action))
			var neighbour:Control = call(action_to_neighbour_map[action])
			if neighbour:
				print(action_to_neighbour_map[action], " ", neighbour)
				_set_is_focused(false)
				neighbour.call_deferred("_set_is_focused", true)

func _set_is_focused(v):
	is_focused = v
	focus_node.add_stylebox_override("panel", style_focus if v else style_empty)

#############################################################
# HELPERS
func __get_valid_focus_target_from_node_path_or_null(path:NodePath):
	if path:
		var n:Node = get_node(path);
		if n:
			if __is_valid_focus_target(n):
				var c:Control = n
				return c
			else:
				printerr("Focus node is not valid PlayerFocusButton with same player_id: " + n.get_name() + ".")
				return null
	return null
	
func __is_valid_focus_target(n:Node)->bool:
	return n and n is Button and n.visible and n.has_method("__is_playerFocusButton") and n.player_id == player_id

func __is_playerFocusButton()->bool: return true

#############################################################
# Finding neighbouring PlayerFocusButtons
func find_focus_left()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_left)
	if manual: return manual
	
	# Otherwise just get prev
	return find_focus_prev()

func find_focus_right()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_right)
	if manual: return manual
	
	# Otherwise just get prev
	return find_focus_next()
	
func find_focus_top()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_top)
	if manual: return manual
	
	# Otherwise just get prev
	return find_focus_prev()

func find_focus_bottom()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_bottom)
	if manual: return manual
	
	# Otherwise just get prev
	return find_focus_next()
	
func find_focus_prev()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_previous)
	if manual: return manual
	
	var from:Node = self
	var parent:Node = from.get_parent()
	
	# Iterate tree upwards until something found or reached root
	while parent:
		# Check direct siblings
		for i in range(from.get_index()-1, -1, -1):
			var child_n:Node = parent.get_child(i)
			if __is_valid_focus_target(child_n):
				var child_c:Control = child_n
				return child_c
				
		from = parent
		parent = from.get_parent()
	return null
	
func find_focus_next()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_next)
	if manual: return manual
	
	var from:Node = self
	var parent:Node = from.get_parent()
	
	# Iterate tree upwards until something found or reached root
	while parent:
		# Check direct siblings
		for i in range(from.get_index()+1, parent.get_child_count()):
			var child_n:Node = parent.get_child(i)
			if __is_valid_focus_target(child_n):
				var child_c:Control = child_n
				return child_c
				
		from = parent
		parent = from.get_parent()
	return null
