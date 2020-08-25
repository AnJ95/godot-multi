tool
extends Control

export var allow_all_players = false
export var player_id = 0
export var is_initially_focused = false
export var is_triggered_by_cancel_action = false

var action_to_function = {
	"ui_left" : "find_focus_left",
	"ui_right" : "find_focus_right",
	"ui_up" : "find_focus_top",
	"ui_down" : "find_focus_bottom",
	"ui_focus_next" : "find_focus_next",
	"ui_focus_prev" : "find_focus_prev"
}

var player:Player
# only required when allow_all_players=true
var player_ids_focussing = []

onready var is_focused:bool setget _set_is_focused

var focus_node:Panel
onready var style_empty = StyleBoxEmpty.new()
onready var style_focus = get_stylebox("focus")

func _ready():
	if allow_all_players and is_initially_focused:
		printerr("Error, PlayerFocusControl can not allow_all_players and is_initially_focused")
	if !allow_all_players:
		player = Multi.player(player_id)
	_set_is_focused(is_initially_focused)
	focus_mode = Control.FOCUS_NONE
	
	add_to_group("PlayerFocus")

func _exit_tree():
	if is_focused:
		var focus = find_focus_next()
		if !focus: focus = find_focus_prev()
		if focus:
			self._set_is_focused(false)
			focus._set_is_focused(true)
		
func _unhandled_input(event:InputEvent):
	# cancel if any player fired ui_cancel
	if is_triggered_by_cancel_action:
		for p_id in range(Multi.MAX_PLAYERS):
			var p = Multi.player(p_id)
			if p.is_event_from_this_player(event) and p.is_event_action(event, "ui_cancel"):
				var ev_click = __get_fake_click_event()
				ev_click.pressed = p.is_event_action_just_pressed(event, "ui_cancel")
				_gui_input(ev_click)
		
	# only do this when focussed
	if !is_focused: return
	
	# invalid id
	if !player: return
	
	# if multiple players have access to this Control:
	# determine from whom the event is
	if allow_all_players:
		player_id = -1
		for p_id in player_ids_focussing:
			if Multi.player(p_id).is_event_from_this_player(event):
				player_id = p_id
				player = Multi.player(p_id)
				break
		if player_id == -1:
			return
		
	# fake mouse_down 
	if player.is_event_action_just_pressed(event, "ui_accept"):
		var ev = __get_fake_click_event()
		ev.pressed = true
		_gui_input(ev)
	# fake mouse_up
	if player.is_event_action_just_released(event, "ui_accept"):
		var ev_click = __get_fake_click_event()
		ev_click.pressed = false
		_gui_input(ev_click)
	
	# focus
	for action in action_to_function.keys():
		if player.is_event_action_just_pressed(event, action):
			var other:Control = call(action_to_function[action])
			if other:
				switch_focus_to(other)
				accept_event()
				break

func switch_focus_to(other:Control)->void:
	_set_is_focused(false, player_id)
	other._set_is_focused(true, player_id)

func _set_is_focused(v, change_player_id=-1):
	is_focused = v
	
	# Extra action if potentially multiple cursors on this Control:
	if allow_all_players:
		# change current player_id
		if change_player_id != -1:
			player_id = change_player_id
			player = Multi.player(player_id)
		# add cursor to list
		if v:
			if !player_ids_focussing.has(player_id):
				player_ids_focussing.append(player_id)
		# remove cursor of this player but keep is_focused if another cursor still there
		else:
			player_ids_focussing.erase(player_id)
			if player_ids_focussing.size() > 0:
				is_focused = true
	
	_set_style_focused(is_focused)
	emit_signal("focus_entered" if is_focused else "focus_exited")
	
	if is_focused:
		# causes ScrollContainers to scroll to this Control
		get_viewport().emit_signal("gui_focus_changed", self)
		
func _set_style_focused(focused:bool):
	if !focus_node:
		focus_node = Panel.new()
		focus_node.anchor_bottom = 1
		focus_node.anchor_right = 1
		focus_node.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(focus_node)
	focus_node.add_stylebox_override("panel", style_focus if focused else style_empty)

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
				printerr("Focus node is not valid PlayerFocus with same player_id: " + n.get_name() + ".")
				return null
	return null
	
func __is_valid_focus_target(n:Node)->bool:
	return n.is_in_group("PlayerFocus") and n.visible and (n.player_id == player_id or n.allow_all_players)

#############################################################
# FOCUS
func find_focus_left()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_left)
	if manual: return manual
	
	return find_focus_direction(Vector2.LEFT)

func find_focus_right()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_right)
	if manual: return manual
	
	return find_focus_direction(Vector2.RIGHT)
	
func find_focus_top()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_top)
	if manual: return manual
	
	return find_focus_direction(Vector2.UP)
	
func find_focus_bottom()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_neighbour_bottom)
	if manual: return manual
	
	return find_focus_direction(Vector2.DOWN)

func find_focus_prev()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_previous)
	if manual: return manual
	
	# Look for left first, then up
	var next = find_focus_direction(Vector2.LEFT)
	if next: return next
	
	return find_focus_direction(Vector2.UP)
	
func find_focus_next()->Control:
	# If the focus property is manually overwritten, attempt to use it.
	var manual = __get_valid_focus_target_from_node_path_or_null(focus_next)
	if manual: return manual
	
	# Look for right first, then down
	var next = find_focus_direction(Vector2.RIGHT)
	if next: return next
	
	return find_focus_direction(Vector2.DOWN)

# The position used for finding other focus elements
func get_focus_pos()->Vector2:
	return get_global_rect().position + 0.5 * get_global_rect().size

func find_focus_direction(dir:Vector2)->Control:
	var best_fits = []
	var best_dst = -1
	
	var pos_a:Vector2 = get_focus_pos()
	
	# STEP 1:
	# Find Btn with smallest dst in dir
	for other in get_tree().get_nodes_in_group("PlayerFocus"):
		if !__is_valid_focus_target(other):
			continue
		
		var pos_b:Vector2 = other.get_focus_pos()
		var dst = (dir.y * pos_b.y - dir.y * pos_a.y) + (dir.x * pos_b.x - dir.x * pos_a.x)
		if dst <= 0:
			continue
		
		# if found better (or first iteration):
		if dst < best_dst or best_fits.size() == 0:
			best_fits = [other]
			best_dst = dst
		# if they have the same distance:
		elif dst == best_dst:
			best_fits.append(other)
	
	# STEP 2:
	# If there are multiple possibilities, take the one
	# with the lowest distance in perpendicular direction
	var best_fit = null
	for other in best_fits:
		var pos_b:Vector2 = other.get_focus_pos()
		var dst = abs(abs(dir.y) * (pos_b.x - pos_a.x) + abs(dir.x) * (pos_b.y - pos_a.y))
		if best_fit == null or dst < best_dst:
			best_fit = other
			best_dst = dst
			
	return best_fit

