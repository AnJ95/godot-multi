tool
extends Button

export(int) var players_min:int = 2 setget _set_players_min
export(int) var players_max:int = 4 setget _set_players_max

const icon_active = preload("res://addons/multi/assets/icons/player.png")
const icon_semiactive = preload("res://addons/multi/assets/icons/player_semiactive.png")
const icon_inactive = preload("res://addons/multi/assets/icons/player_inactive.png")

func _ready():
	expand_icon = true
	recreate()
	Multi.connect("num_connected_players_changed", self, "_on_num_connected_players_changed")
	num_connected_players_changed()
	
func num_connected_players_changed():
	var num = Multi.get_num_connected_players()
	disabled = num < players_min or num > players_max

func _set_text(v):
	text = v
	recreate()
func _set_players_min(v):
	players_min = v
	recreate()
func _set_players_max(v):
	players_max = v
	recreate()
	


func recreate():
	var w = icon_active.get_width()
	var h = icon_active.get_height()
	
	# create empty Image of correct size
	var image:Image = Image.new()
	image.create(w*Multi.MAX_PLAYERS, h, false, Image.FORMAT_RGBA8)
	
	for p in range(players_max):
		var icon = icon_active if p + 1 <= players_min else icon_semiactive
		image.blit_rect(icon.get_data(), Rect2(0, 0, w, h), Vector2(p*w, 0))
	
	# convert Image to ImageTexture
	var texture:ImageTexture = ImageTexture.new()
	texture.create_from_image(image)
	
	icon = texture

