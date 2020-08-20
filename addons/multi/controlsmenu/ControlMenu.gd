tool
extends ScrollContainer

const ControlMenuAction = preload("ControlMenuAction.tscn")

export(String) var filter_actions:String = "^(ui_home)|(ui_end)|(ui_select)|(ui_page_up)|(ui_page_down)|(ui_focus_prev)|(ui_focus_next)"

var player_id:int = 0

onready var root = $Grid

func init(player_id:int):
	self.player_id = player_id
	
func _ready():
	add_actions()
	
	call_deferred("scroll_to_top")

func scroll_to_top():
	scroll_vertical = 0

func add_actions():
	
	# Clear prev children
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()
	
	# get settings
	var inputmap_actions = Multi.__input_map
	
	# Try to use preferred_order for the list of action names ...
	var action_names = Multi.PREFFERED_ACTION_ORDER.duplicate()
	
	# ... but remove what doesn't actually exist ...
	for action_name in action_names:
		if !inputmap_actions.has(action_name):
			action_names.erase(action_name)
	
	# ... and append what's missing
	for action_name in inputmap_actions:
		if action_names.find(action_name) == -1:
			action_names.append(action_name)
	
	# ready regex to filter actions
	var regex = RegEx.new()
	regex.compile(filter_actions)
	
	# add one ControlMenuAction per InputMap action
	for action_name in action_names:
		
		# skip filtered actions
		if regex.search(action_name):
			continue
		
		# create and add instance
		var menu_action_inst = ControlMenuAction.instance()
		menu_action_inst.init(player_id, action_name)
		root.add_child(menu_action_inst)
	
	if root.get_child_count() > 0:
		root.get_child(0).call_deferred("grab_focus")

func reset_to_default():
	#PersistenceMngr.set_state("settingsControls", StateMngr.default_options_controls)
	
	add_actions()
	
	
