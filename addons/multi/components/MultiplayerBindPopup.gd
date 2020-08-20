tool
extends WindowDialog

func _ready():
	var inner:Control = $MarginContainer
	rect_size = inner.rect_size + Vector2(inner.margin_left + inner.margin_right, inner.margin_top + inner.margin_bottom)
