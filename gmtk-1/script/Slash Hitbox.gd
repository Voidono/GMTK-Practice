class_name SlashHitbox
extends Area2D
## Spawned by SlashWeapon.swing() (or AttackState/OverloadState, for
## enemy attacks) once per swing. Unlike Bullet/Projectile (which
## disappears after its first hit, since it's a single travelling
## shot), this stays alive for its whole lifetime and can hit every
## body that overlaps it during that window.
##
## target_group makes this reusable by BOTH sides: SlashWeapon leaves
## it at the default "enemies", enemy attack states set it to "player"
## right after instantiate() - same scene/script, just retargeted.
##
## Scene tree expected:
## SlashHitbox (Area2D)
##  ├─ Sprite2D (optional, for a visible swing effect)
##  └─ CollisionShape2D  <- size/shape this to be your swing's reach and arc
## Collision layer/mask: give it its own layer, mask = whichever group
## it should be able to detect (enemies OR player, not both at once).

@export var damage: int = 15
@export var lifetime: float = 0.15
@export var target_group: StringName = &"enemies"

var _already_hit: Array[Node] = []  # safety net against double-counting one overlap

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# ignore_time_scale=true - an attack should stay snappy even while
	# TimeSlowAbility has slowed everything else down, same reasoning
	# as Player.move()/get_real_delta().
	get_tree().create_timer(lifetime, true, false, true).timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	if body in _already_hit:
		return
	if body.is_in_group(target_group) and body.has_method("take_damage"):
		_already_hit.append(body)
		body.take_damage(damage)
