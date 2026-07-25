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
@export var front_cone_reach: float = 70.0
@export var front_cone_half_width: float = 38.0
@export var finishing_circle_radius: float = 72.0

var _already_hit: Array[Node] = []  # safety net against double-counting one overlap
var _attack_step := 1
var _direction := Vector2.RIGHT

@onready var cone_shape: CollisionPolygon2D = $ConeShape
@onready var circle_shape: CollisionShape2D = $CircleShape

## Configure before the hitbox enters the scene. Steps 1 and 2 are a forward
## cone; step 3 is a full circle centred on the player.
func configure(attack_step: int, direction: Vector2) -> void:
	_attack_step = attack_step
	_direction = direction.normalized() if direction != Vector2.ZERO else Vector2.RIGHT

func _ready() -> void:
	_apply_attack_shape()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	# ignore_time_scale=true - an attack should stay snappy even while
	# TimeSlowAbility has slowed everything else down, same reasoning
	# as Player.move()/get_real_delta().
	get_tree().create_timer(lifetime, true, false, true).timeout.connect(queue_free)

func _apply_attack_shape() -> void:
	if _attack_step == 3:
		rotation = 0.0
		cone_shape.disabled = true
		circle_shape.disabled = false
		var circle := circle_shape.shape as CircleShape2D
		circle.radius = finishing_circle_radius
		return

	rotation = _direction.angle()
	circle_shape.disabled = true
	cone_shape.disabled = false
	cone_shape.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(front_cone_reach, -front_cone_half_width),
		Vector2(front_cone_reach, front_cone_half_width),
	])

func _on_body_entered(body: Node) -> void:
	_deal_damage(body)

func _on_area_entered(area: Area2D) -> void:
	_deal_damage(area.get_parent())

func _deal_damage(target: Node) -> void:
	if not is_instance_valid(target):
		return
	if target in _already_hit:
		return
	if target.is_in_group(target_group) and target.has_method("take_damage"):
		_already_hit.append(target)
		target.take_damage(damage)
