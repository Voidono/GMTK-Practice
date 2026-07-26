class_name ChronoChaseState
extends State
## Identical to ChaseState, except movement is boosted by the inverse
## of Engine.time_scale - same trick Player.move() uses. This enemy
## keeps moving at full real-world speed even while TimeSlowAbility has
## slowed everything else down. The one enemy your bullet-time doesn't
## trivialize.
##
## Its Attack state (if you wire the same AttackState in) is left
## UN-compensated on purpose - the telegraph still slows down normally
## with everything else, so once it commits to a swing you get a
## genuinely readable window. Only its approach ignores your ability.

@export var enemy: Enemy
@export var speed: float = 40.0
@export var attack_state: State
@export var attack_range: float = 50.0

func physics_update(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return

	var offset := player.global_position - enemy.global_position
	var distance := offset.length()

	if distance <= attack_range and attack_state:
		transition_requested.emit(attack_state)
		return

	var compensation := 1.0 / Engine.time_scale if Engine.time_scale > 0.0 else 1.0
	enemy.velocity = offset.normalized() * speed * compensation
	enemy.move_and_slide()
