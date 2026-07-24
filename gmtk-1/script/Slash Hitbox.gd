class_name SlashHitbox
extends Area2D
## Spawned by MeleeWeapon.swing() once per attack. Unlike Bullet (which
## disappears after its first hit, since it's a single projectile),
## this stays alive for its whole lifetime and can hit every enemy that
## overlaps it during that window - that's the actual appeal of melee
## reach/arc over ranged precision.
##
## Scene tree expected:
## SlashHitbox (Area2D)
##  ├─ Sprite2D (optional, for a visible swing effect)
##  └─ CollisionShape2D  <- size/shape this to be your swing's reach and arc
## Set layer/mask same as Bullet was: detects "enemies" only.

@export var damage: int = 15
@export var lifetime: float = 0.15

var _already_hit: Array[Node] = []  # safety net against double-counting one overlap

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	if body in _already_hit:
		return
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		_already_hit.append(body)
		body.take_damage(damage)
