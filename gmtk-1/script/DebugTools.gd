extends Node

## Debug-only playtest tools. This singleton is available in all builds but
## intentionally stays disabled unless Godot runs a debug build.

var enabled := false
var _overlay: DebugOverlay

func _ready() -> void:
	enabled = OS.is_debug_build()
	_overlay = DebugOverlay.new()
	get_tree().root.call_deferred("add_child", _overlay)

func _process(_delta: float) -> void:
	if enabled and _overlay and _overlay.visible:
		_overlay.refresh()

func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return
	var key_event := event as InputEventKey
	if not key_event or not key_event.pressed or key_event.echo:
		return
	if key_event.alt_pressed:
		if key_event.keycode == KEY_P:
			ControlScheme.debug_set_touch_mode(true)
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_O:
			ControlScheme.debug_set_touch_mode(false)
			get_viewport().set_input_as_handled()
			return
	match key_event.keycode:
		KEY_F3:
			_overlay.visible = not _overlay.visible
			if _overlay.visible:
				_overlay.refresh()
			get_viewport().set_input_as_handled()
		KEY_F4:
			_refill_player_time()
			get_viewport().set_input_as_handled()
		KEY_F5:
			_spawn_from_all_spawners()
			get_viewport().set_input_as_handled()
		KEY_F6:
			_spawn_boss_now()
			get_viewport().set_input_as_handled()
		KEY_F7:
			_toggle_spawn_zones()
			get_viewport().set_input_as_handled()

func _refill_player_time() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and player.health:
		player.health.restore_time(player.health.max_time)

func _spawn_from_all_spawners() -> void:
	for spawner_node in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner := spawner_node as EnemySpawner
		if spawner:
			spawner.debug_spawn_one()

func _spawn_boss_now() -> void:
	var director := get_tree().get_first_node_in_group("match_director") as MatchDirector
	if director:
		director.debug_spawn_boss_now()

func _toggle_spawn_zones() -> void:
	for spawner_node in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner := spawner_node as EnemySpawner
		if spawner:
			spawner.debug_toggle_zone()
