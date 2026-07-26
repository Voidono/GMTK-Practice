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
@export var dash_cooldown: float = 0.6

var _timer: float = 0.0
var _direction: Vector2 = Vector2.RIGHT
var _cooldown_remaining: float = 0.0

func _physics_process(delta: float) -> void:
	if _cooldown_remaining > 0.0 and player:
		_cooldown_remaining -= player.get_real_delta(delta)
 
## CombatState checks this before allowing a dash to trigger.
func can_dash() -> bool:
	return _cooldown_remaining <= 0.0
	
func enter() -> void:
	
	if not player:
		push_error("DashingState: 'Player' field is unassigned in the Inspector.")
		return
	if not combat_state:
		push_error("DashingState: 'Combat State' field is unassigned in the Inspector.")
		
	_timer = dash_duration
	_direction = player.last_movement_direction
	_cooldown_remaining = dash_cooldown
	player.play_dash_effect(_direction)

func physics_update(delta: float) -> void:
	if not player:
		return
 
	player.move(_direction * dash_speed)
 
	_timer -= player.get_real_delta(delta)
	if _timer <= 0.0 and combat_state:
		transition_requested.emit(combat_state)
