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
signal match_time_changed(elapsed: float, duration: float)
signal boss_spawned(boss: Node2D)

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var min_radius: float = 210.0   # no-spawn buffer around the player
@export var max_radius: float = 360.0   # outer edge of the spawn zone
@export var spawn_start_delay: float = 0.0 # real seconds before this spawner begins creating enemies
@export var spawn_interval: float = 1.45
@export var minimum_spawn_interval: float = 0.70
@export var spawn_interval_reduction_per_minute: float = 0.15
@export var max_enemies: int = 15
@export var max_enemy_growth_per_minute: int = 2
@export var enemy_group: StringName = &"enemies"  # must match Enemy.gd's add_to_group()
@export var initial_spawn_count: int = 4           # burst-spawn this many immediately on ready
@export var boss_spawn_delay: float = 300.0
@export var boss_spawn_min_distance: float = 360.0
@export var boss_spawn_max_distance: float = 440.0
@export var stop_spawning_after_boss: bool = true
@export var show_debug_zone: bool = false           # draws the ring live in the running game

var _spawn_timer: float = 0.0
var match_elapsed: float = 0.0
var has_spawned_boss := false

func _ready() -> void:
	add_to_group("enemy_spawner")
	if min_radius > max_radius:
		push_warning("EnemySpawner: min_radius was greater than max_radius - swapping them.")
		var tmp := min_radius
		min_radius = max_radius
		max_radius = tmp

	if show_debug_zone:
		queue_redraw()

	if spawn_start_delay <= 0.0:
		for i in initial_spawn_count:
			_try_spawn()
	match_time_changed.emit(match_elapsed, boss_spawn_delay)

func _process(delta: float) -> void:
	var real_delta := delta / Engine.time_scale if Engine.time_scale > 0.0 else delta
	if has_spawned_boss:
		return
	match_elapsed = minf(match_elapsed + real_delta, boss_spawn_delay)
	match_time_changed.emit(match_elapsed, boss_spawn_delay)
	if match_elapsed >= boss_spawn_delay:
		_spawn_boss()

func _physics_process(delta: float) -> void:
	if has_spawned_boss and stop_spawning_after_boss:
		return
	if match_elapsed < spawn_start_delay:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _current_spawn_interval()
		_try_spawn()

func _try_spawn() -> void:
	if not enemy_scene:
		push_warning("EnemySpawner: no enemy_scene assigned in the Inspector")
		return

	if get_tree().get_nodes_in_group(enemy_group).size() >= _current_enemy_cap():
		return

	var enemy := enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _random_point_in_zone()
	enemy_spawned.emit(enemy)

func _random_point_in_zone() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var center := player.global_position if is_instance_valid(player) else global_position
	return _random_point_around(center, min_radius, max_radius)

func _spawn_boss() -> void:
	has_spawned_boss = true
	if not boss_scene:
		push_warning("EnemySpawner: boss_spawn_delay elapsed, but no boss_scene is assigned.")
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var center := player.global_position if is_instance_valid(player) else global_position
	var boss := boss_scene.instantiate() as Node2D
	get_tree().current_scene.add_child(boss)
	boss.global_position = _random_point_around(center, boss_spawn_min_distance, boss_spawn_max_distance)
	boss_spawned.emit(boss)

func _random_point_around(center: Vector2, minimum: float, maximum: float) -> Vector2:
	var angle := randf_range(0.0, TAU)
	# sqrt spread keeps spawn density even across the ring's area.
	var radius := sqrt(randf_range(minimum * minimum, maximum * maximum))
	return center + Vector2.RIGHT.rotated(angle) * radius

func _current_spawn_interval() -> float:
	var elapsed_minutes := match_elapsed / 60.0
	return maxf(minimum_spawn_interval, spawn_interval - elapsed_minutes * spawn_interval_reduction_per_minute)

func _current_enemy_cap() -> int:
	return max_enemies + int(match_elapsed / 60.0) * max_enemy_growth_per_minute

## Only runs while show_debug_zone is on. Draws in local space, so this
## stays correctly centered on the player automatically as it moves -
## no per-frame redraw needed since the shape itself never changes.
func _draw() -> void:
	if not show_debug_zone:
		return
	draw_arc(Vector2.ZERO, min_radius, 0.0, TAU, 48, Color(1.0, 0.3, 0.3, 0.6), 2.0)
	draw_arc(Vector2.ZERO, max_radius, 0.0, TAU, 48, Color(0.3, 1.0, 0.3, 0.6), 2.0)
