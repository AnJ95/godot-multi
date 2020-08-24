tool
extends WindowDialog

var inner:Control

func _ready():
	window_title = "Players"
	inner = preload("res://addons/multi/bindpopup/MultiPlayerBindPopupInner.tscn").instance()
	add_child(inner)
	__update_size()
	add_to_group("MultiPlayerBindPopup")
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	inner.connect("draw", self, "__update_size")


func __update_size():
	rect_size = inner.rect_size
	
func set_theme(theme:Theme):
	self.theme = theme
	__update_size()
