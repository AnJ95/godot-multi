tool
extends Button

export(int) var players_min:int = 2 setget _set_players_min
export(int) var players_max:int = 4 setget _set_players_max

export var icon_active = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_active
export var icon_optional = preload("res://addons/multi/assets/icons/player_semiactive.png") setget _set_icon_optional
export var icon_inactive:StreamTexture = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_inactive


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
	image.create(w*Multi.MAX_PLAYERS, h, false, Image.FORMAT_RGBA8)
	
	for p in range(Multi.MAX_PLAYERS):
		var icon = icon_inactive
		if p + 1 <= players_max: icon = icon_optional
		if p + 1 <= players_min: icon = icon_active
		
		if icon:
			image.blit_rect(icon.get_data(), Rect2(0, 0, w, h), Vector2(p*w, 0))
	
	# convert Image to ImageTexture
	var texture:ImageTexture = ImageTexture.new()
	texture.create_from_image(image)
	
	icon = texture
	
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

