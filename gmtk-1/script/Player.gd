class_name Player
extends CharacterBody2D
## Deliberately thin: reads raw input and mouse-aim every frame and
## exposes them as plain data. Movement itself (move_and_slide) now
## belongs to whichever State is active - CombatState drives normal
## WASD movement, DashingState drives the dash - so there's never a
## conflict over who's allowed to set velocity on a given frame.

@export var speed: float = 150.0
@onready var animation_player := $AnimationPlayer
@onready var weapon_point: Marker2D = $WeaponPoint
## Raw WASD input this frame - can be Vector2.ZERO when standing still.
var input_vector: Vector2 = Vector2.ZERO

## Last non-zero input_vector. What "forward" means for a dash even if
## you're not currently holding a direction when you trigger it.
var last_movement_direction: Vector2 = Vector2.RIGHT

## Direction from the player to the mouse cursor, updated every frame
## regardless of state - this is what the slash aims toward. Decoupled
## from movement on purpose: you can strafe one way while facing/
## attacking another, same as most top-down action games.
var aim_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	input_vector = Input.get_vector("right", "left", "up", "down")
	if input_vector.length() > 0.0:
		last_movement_direction = input_vector.normalized()

	aim_direction = (get_global_mouse_position() - global_position).normalized()
	if aim_direction != Vector2.ZERO:
		weapon_point.rotation = aim_direction.angle()
## States call this instead of setting velocity + move_and_slide()
## themselves. Counteracts Engine.time_scale so the player keeps moving
## at normal real-world speed even while TimeSlowAbility has slowed
## everything else down - this is what actually sells "I got faster"
## instead of "the game got choppy." Centralized here once instead of
## duplicated in every state that moves the player.
func move(desired_velocity: Vector2) -> void:
	var compensation := 1.0 / Engine.time_scale if Engine.time_scale > 0.0 else 1.0
	velocity = desired_velocity * compensation
	move_and_slide()

## Recovers real (unscaled) seconds from a scaled delta - for any
## player-related timer (dash duration, attack lifetime) that should
## also stay snappy and not stretch out during slow-mo, same reasoning
## as move() above.
func get_real_delta(scaled_delta: float) -> float:
	return scaled_delta / Engine.time_scale if Engine.time_scale > 0.0 else scaled_delta
