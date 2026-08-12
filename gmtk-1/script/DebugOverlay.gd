class_name DebugOverlay
extends CanvasLayer

var _panel: ColorRect
var _status_label: Label

func _ready() -> void:
	layer = 100
	_panel = ColorRect.new()
	_panel.color = Color(0.025, 0.035, 0.07, 0.9)
	_panel.position = Vector2(12.0, 52.0)
	_panel.size = Vector2(330.0, 250.0)
	add_child(_panel)

	_status_label = Label.new()
	_status_label.position = Vector2(12.0, 10.0)
	_status_label.size = Vector2(306.0, 230.0)
	_status_label.add_theme_color_override("font_color", Color(0.75, 0.92, 1.0))
	_status_label.add_theme_font_size_override("font_size", 16)
	_panel.add_child(_status_label)
	visible = false

func refresh() -> void:
	var mode_name := "MOBILE" if ControlScheme.is_touch else "PC"
	var lines := PackedStringArray(["DEBUG MODE  [F3 close]", "F4 Refill time   F5 Spawn waves", "F6 Spawn boss    F7 Spawn zones", "Alt+P Mobile | Alt+O PC: %s" % mode_name, ""])
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and player.health:
		lines.append("Player time: %.1f / %.1f" % [player.health.current, player.health.max_time])
		lines.append("Position: (%.0f, %.0f)" % [player.global_position.x, player.global_position.y])
	else:
		lines.append("Player: not found")

	var director := get_tree().get_first_node_in_group("match_director") as MatchDirector
	if director:
		lines.append("Boss: %s | clock %.1f / %.1f" % ["spawned" if director.has_spawned_boss else "waiting", director.match_elapsed, director.boss_spawn_delay])

	for spawner_node in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner := spawner_node as EnemySpawner
		if spawner:
			lines.append("%s: %d / %d" % [spawner.name, spawner.debug_live_count(), spawner.debug_current_cap()])
	_status_label.text = "\n".join(lines)
