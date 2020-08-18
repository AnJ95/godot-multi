tool
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

var focus_node:Panel
onready var style_empty = StyleBoxEmpty.new()
onready var style_focus = get_stylebox("focus")

func _ready():
	_set_is_focused(is_initially_focused)
	enabled_focus_mode = Control.FOCUS_NONE
	
func check_focus_node():
	if !focus_node:
		focus_node = Panel.new()
		focus_node.anchor_bottom = 1
		focus_node.anchor_right = 1
		focus_node.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(focus_node)
		
func _process(_delta):
	# only do this when focussed
	if !is_focused:
		return
	
	if player.is_action_just_pressed("ui_accept") or player.is_action_just_pressed("ui_select"):
		var ev = __get_fake_click_event()
		ev.pressed = true
		Input.parse_input_event(ev)
		
	if player.is_action_just_released("ui_accept") or player.is_action_just_released("ui_select"):
		var ev_click = __get_fake_click_event()
		ev_click.pressed = false
		
		# a little hacky, but the motion is required if the mouse has moved
		# since button_down
		var ev_motion = InputEventMouseMotion.new()
		ev_motion.position = ev_click.position
		
		Input.parse_input_event(ev_motion)
		Input.parse_input_event(ev_click)
		
		
	for action in action_to_neighbour_map.keys():
		if player.is_action_just_pressed(action):
			var neighbour:Control = call(action_to_neighbour_map[action])
			if neighbour:
				_set_is_focused(false)
				neighbour.call_deferred("_set_is_focused", true)
				
	

func _set_is_focused(v):
	check_focus_node()
	is_focused = v
	focus_node.add_stylebox_override("panel", style_focus if v else style_empty)

#############################################################
# HELPERS
func __get_fake_click_event()->InputEventMouseButton:
	var ev = InputEventMouseButton.new()
	ev.button_index = BUTTON_LEFT
	ev.position = get_global_rect().position + 0.5 * get_global_rect().size
	return ev
	
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
