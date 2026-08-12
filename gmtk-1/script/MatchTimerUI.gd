class_name MatchTimerUI
extends Label

func _ready() -> void:
	call_deferred("_bind_to_director")

func _bind_to_director() -> void:
	var director := get_tree().get_first_node_in_group("match_director") as MatchDirector
	if not director:
		visible = false
		return
	director.match_time_changed.connect(_on_match_time_changed)
	director.boss_spawned.connect(_on_boss_spawned)
	_on_match_time_changed(director.match_elapsed, director.boss_spawn_delay)

func _on_match_time_changed(elapsed: float, duration: float) -> void:
	var remaining := maxf(duration - elapsed, 0.0)
	text = "BOSS IN %02d:%02d" % [floori(remaining / 60.0), floori(fmod(remaining, 60.0))]

func _on_boss_spawned(_boss: Node2D) -> void:
	text = "BOSS HAS ARRIVED"
