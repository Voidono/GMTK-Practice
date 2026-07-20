class_name EnemySpawner
extends Node2D
## Attach as a child of Player (or anything you want enemies to spawn
## around). Because it inherits the parent's transform, its own
## global_position IS the player's position - no group lookup needed.
##
## Spawns Enemy instances at random points inside a ring (an annulus,
## not a filled disc): min_radius keeps enemies from spawning right on
## top of the player, max_radius is the outer edge of the zone.

signal enemy_spawned(enemy: Node2D)

@export var enemy_scene: PackedScene
@export var min_radius: float = 150.0   # no-spawn buffer around the player
@export var max_radius: float = 450.0   # outer edge of the spawn zone
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 12
@export var enemy_group: StringName = &"enemies"  # must match Enemy.gd's add_to_group()
@export var initial_spawn_count: int = 3           # burst-spawn this many immediately on ready
@export var show_debug_zone: bool = false           # draws the ring live in the running game

var _spawn_timer: float = 0.0

func _ready() -> void:
	if min_radius > max_radius:
		push_warning("EnemySpawner: min_radius was greater than max_radius - swapping them.")
		var tmp := min_radius
		min_radius = max_radius
		max_radius = tmp

	if show_debug_zone:
		queue_redraw()

	for i in initial_spawn_count:
		_try_spawn()

func _physics_process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_try_spawn()

func _try_spawn() -> void:
	if not enemy_scene:
		push_warning("EnemySpawner: no enemy_scene assigned in the Inspector")
		return

	if get_tree().get_nodes_in_group(enemy_group).size() >= max_enemies:
		return

	var enemy := enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _random_point_in_zone()
	enemy_spawned.emit(enemy)

func _random_point_in_zone() -> Vector2:
	var angle := randf_range(0.0, TAU)
	# sqrt spread keeps spawn density even across the ring's area,
	# instead of bunching up near the inner edge.
	var r := sqrt(randf_range(min_radius * min_radius, max_radius * max_radius))
	return global_position + Vector2.RIGHT.rotated(angle) * r

## Only runs while show_debug_zone is on. Draws in local space, so this
## stays correctly centered on the player automatically as it moves -
## no per-frame redraw needed since the shape itself never changes.
func _draw() -> void:
	if not show_debug_zone:
		return
	draw_arc(Vector2.ZERO, min_radius, 0.0, TAU, 48, Color(1.0, 0.3, 0.3, 0.6), 2.0)
	draw_arc(Vector2.ZERO, max_radius, 0.0, TAU, 48, Color(0.3, 1.0, 0.3, 0.6), 2.0)
