class_name EnemySpawner
extends Node2D

## Reusable enemy-wave template. Add one of these for every enemy type a
## map needs, then assign that type's scene in the Inspector. The match/boss
## timeline deliberately lives in MatchDirector, not in this component.

signal enemy_spawned(enemy: Node2D)

@export var enemy_scene: PackedScene
@export var min_radius: float = 210.0
@export var max_radius: float = 360.0
@export var spawn_start_delay: float = 0.0
@export var spawn_interval: float = 1.45
@export var minimum_spawn_interval: float = 0.70
@export var spawn_interval_reduction_per_minute: float = 0.15
@export var max_enemies: int = 15
@export var max_enemy_growth_per_minute: int = 2
@export var initial_spawn_count: int = 4
@export var show_debug_zone: bool = false

var _spawn_timer := 0.0
var _elapsed := 0.0
var _spawned_enemies: Array[Node2D] = []

func _ready() -> void:
	add_to_group("enemy_spawners")
	if min_radius > max_radius:
		push_warning("EnemySpawner: min_radius was greater than max_radius - swapping them.")
		var radius_swap := min_radius
		min_radius = max_radius
		max_radius = radius_swap
	if show_debug_zone:
		queue_redraw()
	if spawn_start_delay <= 0.0:
		for i in initial_spawn_count:
			_try_spawn()

func _process(delta: float) -> void:
	_elapsed += _real_delta(delta)

func _physics_process(delta: float) -> void:
	if _elapsed < spawn_start_delay:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _current_spawn_interval()
		_try_spawn()

func _try_spawn() -> void:
	if not enemy_scene:
		push_warning("EnemySpawner: no enemy_scene assigned.")
		return
	_prune_spawned_enemies()
	if _spawned_enemies.size() >= _current_enemy_cap():
		return
	var enemy := enemy_scene.instantiate() as Node2D
	if not enemy:
		push_error("EnemySpawner: enemy_scene must have a Node2D root.")
		return
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _random_point_in_zone()
	_spawned_enemies.append(enemy)
	enemy_spawned.emit(enemy)

func _prune_spawned_enemies() -> void:
	for index in range(_spawned_enemies.size() - 1, -1, -1):
		if not is_instance_valid(_spawned_enemies[index]):
			_spawned_enemies.remove_at(index)

func _random_point_in_zone() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var center := player.global_position if is_instance_valid(player) else global_position
	var angle := randf_range(0.0, TAU)
	var radius := sqrt(randf_range(min_radius * min_radius, max_radius * max_radius))
	return center + Vector2.RIGHT.rotated(angle) * radius

func _current_spawn_interval() -> float:
	return maxf(minimum_spawn_interval, spawn_interval - (_elapsed / 60.0) * spawn_interval_reduction_per_minute)

func _current_enemy_cap() -> int:
	return max_enemies + int(_elapsed / 60.0) * max_enemy_growth_per_minute

func _real_delta(delta: float) -> float:
	return delta / Engine.time_scale if Engine.time_scale > 0.0 else delta

func _draw() -> void:
	if not show_debug_zone:
		return
	draw_arc(Vector2.ZERO, min_radius, 0.0, TAU, 48, Color(1.0, 0.3, 0.3, 0.6), 2.0)
	draw_arc(Vector2.ZERO, max_radius, 0.0, TAU, 48, Color(0.3, 1.0, 0.3, 0.6), 2.0)

## Public playtest API. Keep debug behavior here rather than reaching into
## private fields from DebugTools, so the spawner remains safe to refactor.
func debug_spawn_one() -> void:
	_try_spawn()

func debug_live_count() -> int:
	_prune_spawned_enemies()
	return _spawned_enemies.size()

func debug_current_cap() -> int:
	return _current_enemy_cap()

func debug_toggle_zone() -> void:
	show_debug_zone = not show_debug_zone
	queue_redraw()
