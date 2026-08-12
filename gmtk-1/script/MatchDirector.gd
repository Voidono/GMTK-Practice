class_name MatchDirector
extends Node

## One per map. Owns the match clock and boss spawn so adding more enemy
## spawners never changes when, or how often, the boss arrives.

signal match_time_changed(elapsed: float, duration: float)
signal boss_spawned(boss: Node2D)

@export var boss_scene: PackedScene
@export var boss_spawn_delay: float = 180.0
@export var boss_spawn_min_distance: float = 360.0
@export var boss_spawn_max_distance: float = 440.0

var match_elapsed := 0.0
var has_spawned_boss := false

func _ready() -> void:
	add_to_group("match_director")
	match_time_changed.emit(match_elapsed, boss_spawn_delay)

func _process(delta: float) -> void:
	if has_spawned_boss:
		return
	var real_delta := delta / Engine.time_scale if Engine.time_scale > 0.0 else delta
	match_elapsed = minf(match_elapsed + real_delta, boss_spawn_delay)
	match_time_changed.emit(match_elapsed, boss_spawn_delay)
	if match_elapsed >= boss_spawn_delay:
		_spawn_boss()

func _spawn_boss() -> void:
	has_spawned_boss = true
	if not boss_scene:
		push_warning("MatchDirector: boss_spawn_delay elapsed, but no boss_scene is assigned.")
		return
	var boss := boss_scene.instantiate() as Node2D
	if not boss:
		push_error("MatchDirector: boss_scene must have a Node2D root.")
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var center := player.global_position if is_instance_valid(player) else Vector2.ZERO
	var angle := randf_range(0.0, TAU)
	var radius := sqrt(randf_range(boss_spawn_min_distance * boss_spawn_min_distance, boss_spawn_max_distance * boss_spawn_max_distance))
	get_tree().current_scene.add_child(boss)
	boss.global_position = center + Vector2.RIGHT.rotated(angle) * radius
	boss_spawned.emit(boss)

func debug_spawn_boss_now() -> void:
	if not has_spawned_boss:
		_spawn_boss()
