class_name Gun
extends Marker2D
## Attach this script directly to your Muzzle node (a Marker2D). The gun
## IS the muzzle - one node, one job. It owns everything about shooting:
## fire rate, ammo, reload timing. States never touch Bullet.tscn or
## build bullets themselves; they just call try_fire()/start_reload()
## and react to this node's signals.

signal fired(bullet: Node)
signal ammo_changed(current: int, max: int)
signal emptied
signal reloaded

@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0     # seconds between shots
@export var magazine_size: int = 6
@export var reload_time: float = 1.5

var ammo: int
var _fire_cooldown: float = 0.0
var _reload_timer: float = 0.0
var _reloading: bool = false

func _ready() -> void:
	ammo = magazine_size

func _physics_process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta

	if _reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_finish_reload()

func can_fire() -> bool:
	return not _reloading and _fire_cooldown <= 0.0 and ammo > 0

## Aims the gun and, if off cooldown/reloading/empty, fires a bullet.
## Returns true if a shot was actually fired.
func try_fire(direction: Vector2) -> bool:
	if not can_fire():
		return false

	_spawn_bullet(direction)
	ammo -= 1
	_fire_cooldown = fire_rate
	ammo_changed.emit(ammo, magazine_size)

	if ammo <= 0:
		emptied.emit()

	return true

func start_reload() -> void:
	if _reloading:
		return
	_reloading = true
	_reload_timer = reload_time

func _finish_reload() -> void:
	_reloading = false
	ammo = magazine_size
	ammo_changed.emit(ammo, magazine_size)
	reloaded.emit()

func _spawn_bullet(direction: Vector2) -> void:
	if not bullet_scene:
		push_warning("Gun: no bullet_scene assigned in the Inspector")
		return

	var bullet := bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(direction)
	fired.emit(bullet)
