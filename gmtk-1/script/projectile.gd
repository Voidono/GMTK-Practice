class_name Projectile
extends Area2D
## Generalized revival of the very first version's bullet.gd - travels
## in a straight line, damages whatever's in target_group on contact.
## Same target_group trick as SlashHitbox: defaults to "enemies", but
## RangedAttackState (Slinger) retargets it to "player" at spawn time.
##
## Scene tree expected:
## Projectile (Area2D)
##  ├─ Sprite2D
##  └─ CollisionShape2D
## Collision layer/mask same rule as SlashHitbox.

@export var speed: float = 400.0
@export var damage: int = 8
@export var lifetime: float = 3.0
@export var target_group: StringName = &"enemies"
@export var spawn_scene: PackedScene

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime, true, false, true).timeout.connect(_expire)

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(target_group) and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _expire() -> void:
	if spawn_scene:
		var spawned := spawn_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(spawned)
		spawned.global_position = global_position
	queue_free()
