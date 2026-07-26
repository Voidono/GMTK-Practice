class_name AttackState
extends State
## Generic melee telegraph-then-strike, reusable by any enemy - grunts,
## and (via the exact same script, just different tuning) the boss's
## melee phase. enter() starts a telegraph window - hook a visual tell
## here (flash color, wind-up animation) once you have art/animation;
## this project is code-only so far, so the timing is real but the
## "tell" itself is invisible until you add one.
##
## After telegraph elapses, spawns a hitbox aimed at the player -
## reusing SlashHitbox, retargeted via target_group to hit "player"
## instead of "enemies" - then hands back to chase_state.

@export var enemy: Enemy
@export var chase_state: State
@export var hitbox_scene: PackedScene
@export var telegraph_duration: float = 0.5
@export var damage: int = 10
@export var attack_reach: float = 30.0

var _timer: float = 0.0
var _has_struck: bool = false

func enter() -> void:
	_timer = telegraph_duration
	_has_struck = false
	if enemy:
		enemy.velocity = Vector2.ZERO  # stand still through the windup

func physics_update(delta: float) -> void:
	_timer -= delta

	if _timer <= 0.0 and not _has_struck:
		_strike()

	if _timer <= 0.0 and chase_state:
		transition_requested.emit(chase_state)

func _strike() -> void:
	_has_struck = true

	if not hitbox_scene or not enemy:
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return

	var direction := (player.global_position - enemy.global_position).normalized()
	var hitbox := hitbox_scene.instantiate()
	get_tree().current_scene.add_child(hitbox)
	hitbox.global_position = enemy.global_position + direction * attack_reach
	hitbox.rotation = direction.angle()
	hitbox.target_group = &"player"
	hitbox.damage = damage
