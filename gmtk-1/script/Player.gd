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
@onready var character_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_effect: AnimatedSprite2D = $DashEffect
@export var health: CountdownHealth
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
var is_dashing := false

func _ready() -> void:
	add_to_group("player")
	if health:
		health.died.connect(_on_died)
	else:
		push_error("Player: 'Health' field is unassigned in the Inspector - enemies can't damage you.")

## Duck-typed entry point enemy attacks call, same pattern as
## Enemy.take_damage() forwarding to its own Health component.
func take_damage(amount: int) -> void:
	if health and not is_dashing:
		health.take_damage(amount)

## Called by Enemy on death (see enemy.gd's _on_died()) - killing
## enemies is the only way to buy back time.
func on_enemy_killed() -> void:
	if health:
		health.reward_kill()

func collect_soul(value: float) -> void:
	if health:
		health.restore_time(value)

func set_dashing(active: bool) -> void:
	is_dashing = active

func _on_died() -> void:
	queue_free()
func _physics_process(_delta: float) -> void:
	input_vector = Input.get_vector("right", "left", "up", "down")
	if input_vector.length() > 0.0:
		last_movement_direction = input_vector.normalized()
	_update_movement_animation()

	aim_direction = (get_global_mouse_position() - global_position).normalized()
	if aim_direction != Vector2.ZERO:
		weapon_point.rotation = aim_direction.angle()

func _update_movement_animation() -> void:
	if input_vector == Vector2.ZERO:
		character_sprite.stop()
		return

	var animation_name: StringName
	if absf(input_vector.x) > absf(input_vector.y):
		animation_name = &"right" if input_vector.x > 0.0 else &"left"
	else:
		animation_name = &"walk" if input_vector.y > 0.0 else &"back"

	if character_sprite.animation != animation_name or not character_sprite.is_playing():
		character_sprite.play(animation_name)
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

func play_dash_effect(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	dash_effect.position = -direction.normalized() * 18.0
	dash_effect.rotation = direction.angle()
	dash_effect.show()
	dash_effect.play(&"dash")
