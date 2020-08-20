tool
extends WindowDialog

func _ready():
	window_title = "Connect Controllers"
	var inner:Control = preload("res://addons/multi/bindpopup/MultiPlayerBindPopupInner.tscn").instance()
	add_child(inner)
	rect_size = inner.rect_size + Vector2(inner.margin_left + inner.margin_right, inner.margin_top + inner.margin_bottom)
