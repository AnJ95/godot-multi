# Godot Multi

![Godot Multi](https://raw.githubusercontent.com/AnJ95/godot-multi/master/addons/multi/assets/logo/logo256.png "Godot Multi")

All the tools you need to create a local multiplayer game in Godot!

---

:bell: **This plugin is currently in development**

---

## Planned feature List
* Manage keyboard and connected input devices
* Uses InputMap bindings in the project settings window
* Multiplayer controls menu
* High level classes `Player`, `Controller`
* Accompanying signals like `controller_connected` and `controller_assigned_to_player`
* A toolkit of custom Control elements that may be useful
* A small project to showcase it all


## Sneak Peek
```gdscript
extends KinematicBody2D

# get Player object
export(int) var player_id:int = 0
onready var player = Multi.player(player_id)

# some character vars
const SPEED = 80
var velocity = Vector2()

func _physics_process(_delta):

	# use functions you are familiar with
	velocity.x = SPEED * (player.get_action_strength("ui_right") - player.get_action_strength("ui_left"))
	velocity.y = SPEED * (player.get_action_strength("ui_down") - player.get_action_strength("ui_up"))

	velocity = move_and_slide(velocity, Vector2.UP)

```
