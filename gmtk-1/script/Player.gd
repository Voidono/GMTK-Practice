class_name Player
extends CharacterBody2D
## Player is deliberately "dumb" now - just movement. It knows nothing
## about guns, targeting, or states. Everything else is wired together
## in the Inspector between sibling nodes (see README).

signal direction_changed(direction: Vector2)

@export var speed: float = 150.0

## Last non-zero movement direction, exposed for anything that wants
## a fallback aim direction (e.g. EngageState when there's no target).
var facing_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	# Swap these action names for your own Input Map if you have one;
	# ui_left/right/up/down work out of the box with no setup.
	var input_dir := Input.get_vector("right", "left", "up", "down")
	velocity = input_dir * speed
	move_and_slide()

	if input_dir.length() > 0.0:
		var new_direction := input_dir.normalized()
		if new_direction != facing_direction:
			facing_direction = new_direction
			direction_changed.emit(facing_direction)
