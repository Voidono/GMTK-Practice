class_name ChaseState
extends State
## Same State base class the Player uses. Right now Enemy only has one
## state, but it's structured to make adding more trivial later -
## e.g. an Attack state entered when close enough, or a Fleeing state
## at low health, each wired in with their own @export transition
## targets exactly like EngageState/ReloadState.

@export var enemy: Enemy
@export var speed: float = 40.0

func physics_update(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return

	var direction := (player.global_position - enemy.global_position).normalized()
	enemy.velocity = direction * speed
	enemy.move_and_slide()
