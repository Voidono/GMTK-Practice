class_name DashingState
extends State
## Rename target: FileSystem dock, right-click your old reload_state.gd
## -> Rename -> "dashing_state.gd", then paste this content in. Class
## was already named DashingState - only the filename was mismatched.
##
## The one genuinely state-shaped piece of this pivot: a real
## enter/exit, briefly overrides normal movement entirely, and is a
## natural place to add i-frames later.
##
## Dash direction follows WASD (last_movement_direction), independent
## of aim - lets you dash one way while facing/slashing another.

@export var player: Player
@export var combat_state: State
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.18

var _timer: float = 0.0
var _direction: Vector2 = Vector2.RIGHT

func enter() -> void:
	_timer = dash_duration
	_direction = player.last_movement_direction

func physics_update(delta: float) -> void:
	player.velocity = _direction * dash_speed
	player.move_and_slide()

	_timer -= delta
	if _timer <= 0.0:
		transition_requested.emit(combat_state)
