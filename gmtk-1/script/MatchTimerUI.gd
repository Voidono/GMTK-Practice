class_name MatchTimerUI
extends Label

func _ready() -> void:
	call_deferred("_bind_to_spawner")

func _bind_to_spawner() -> void:
	var spawner := get_tree().get_first_node_in_group("enemy_spawner") as EnemySpawner
	if not spawner:
		push_warning("MatchTimerUI: no EnemySpawner was found.")
		return
	spawner.match_time_changed.connect(_on_match_time_changed)
	spawner.boss_spawned.connect(_on_boss_spawned)
	_on_match_time_changed(spawner.match_elapsed, spawner.boss_spawn_delay)

func _on_match_time_changed(elapsed: float, duration: float) -> void:
	var remaining := maxf(duration - elapsed, 0.0)
	text = "BOSS IN %02d:%02d" % [floori(remaining / 60.0), floori(fmod(remaining, 60.0))]

func _on_boss_spawned(_boss: Node2D) -> void:
	text = "BOSS HAS ARRIVED"
