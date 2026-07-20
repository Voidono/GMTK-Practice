class_name EngageState
extends State
## Everything this state needs is dragged in via the Inspector - it
## never looks anything up by path or name. It reacts to Targeting's
## signals instead of polling for a target every frame, and reacts to
## Gun's `emptied` signal to know when to hand off to Reload - it
## doesn't track ammo itself at all, Gun owns that.

@export var gun: Gun
@export var targeting: Targeting
@export var player: Player
@export var reload_state: State
@export var aim_turn_speed: float = 10.0

var _current_target: Node2D

func enter() -> void:
	_current_target = targeting.current_target
	targeting.target_acquired.connect(_on_target_acquired)
	targeting.target_lost.connect(_on_target_lost)
	gun.emptied.connect(_on_gun_emptied)

func exit() -> void:
	targeting.target_acquired.disconnect(_on_target_acquired)
	targeting.target_lost.disconnect(_on_target_lost)
	gun.emptied.disconnect(_on_gun_emptied)

func physics_update(delta: float) -> void:
	var aim_direction := _get_aim_direction()

	gun.global_rotation = lerp_angle(gun.global_rotation, aim_direction.angle(), aim_turn_speed * delta)
	gun.try_fire(aim_direction)

## Nearest known target if one exists and is still alive, otherwise
## wherever the player is currently moving/facing.
func _get_aim_direction() -> Vector2:
	if _current_target and is_instance_valid(_current_target):
		return (_current_target.global_position - gun.global_position).normalized()
	return player.facing_direction

func _on_target_acquired(target: Node2D) -> void:
	_current_target = target

func _on_target_lost() -> void:
	_current_target = null

func _on_gun_emptied() -> void:
	transition_requested.emit(reload_state)
