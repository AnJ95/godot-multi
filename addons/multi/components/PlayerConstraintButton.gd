tool
extends Button

export(int) var players_min:int = 2 setget _set_players_min
export(int) var players_max:int = 4 setget _set_players_max

export var icon_active = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_active
export var icon_optional = preload("res://addons/multi/assets/icons/player_semiactive.png") setget _set_icon_optional
export var icon_inactive:StreamTexture = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_inactive

export var icon_margin_left = 2 setget _set_icon_margin_left
export var icon_margin_right = 12 setget _set_icon_margin_right
export var icon_margin_top = 2 setget _set_icon_margin_top
export var icon_margin_bottom = 2 setget _set_icon_margin_bottom
export var icon_margin_between = 2 setget _set_icon_margin_between

#############################################################
# LIFECYCLE
func _ready():
	expand_icon = true
	recreate()
	
	# Await changes but trigger handler initially
	Multi.connect("num_assigned_players_changed", self, "_on_num_assigned_players_changed")
	_on_num_assigned_players_changed(Multi.get_num_assigned_players())
	
func _on_num_assigned_players_changed(num):
	disabled = num < players_min or num > players_max

func recreate():
	var w = icon_active.get_width()
	var h = icon_active.get_height()
	
	# create empty Image of correct size
	var image:Image = Image.new()
	image.create(
		w*Multi.MAX_PLAYERS + icon_margin_between*(Multi.MAX_PLAYERS-1) + icon_margin_left + icon_margin_right,
		h + icon_margin_top + icon_margin_bottom,
		false, Image.FORMAT_RGBA8
	)
	
	for p in range(Multi.MAX_PLAYERS):
		var cur_icon = icon_inactive
		if p + 1 <= players_max: cur_icon = icon_optional
		if p + 1 <= players_min: cur_icon = icon_active
		
		if cur_icon in [icon_active, icon_optional]:
			var player = Multi.player(p)
			if player:
				cur_icon = modulate_texture(cur_icon, player.get_player_color())
		
		if cur_icon:
			image.blit_rect(cur_icon.get_data(), Rect2(0, 0, w, h), Vector2(p*(w+icon_margin_between) + icon_margin_left, icon_margin_top))
	
	# convert Image to ImageTexture
	var texture:ImageTexture = ImageTexture.new()
	texture.create_from_image(image)
	
	icon = texture

func modulate_texture(texture:Texture, color:Color)->Texture:
	var image:Image = texture.get_data().duplicate(true)
	
	image.lock()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			image.set_pixel(x, y, image.get_pixel(x, y) * color)
	image.unlock()
	
	# convert Image to ImageTexture
	var new_texture:ImageTexture = ImageTexture.new()
	new_texture.create_from_image(image)
	
	return new_texture
#############################################################
# SETTERS
func _set_players_min(v):
	players_min = v
	recreate()
func _set_players_max(v):
	players_max = v
	recreate()
	
func _set_icon_active(v):
	icon_active = v
	recreate()
func _set_icon_optional(v):
	icon_optional = v
	recreate()
func _set_icon_inactive(v):
	icon_inactive = v
	recreate()

func _set_icon_margin_left(v):
	icon_margin_left = v
	recreate()
func _set_icon_margin_right(v):
	icon_margin_right = v
	recreate()
func _set_icon_margin_top(v):
	icon_margin_top = v
	recreate()
func _set_icon_margin_bottom(v):
	icon_margin_bottom = v
	recreate()
func _set_icon_margin_between(v):
	icon_margin_between = v
	recreate()
