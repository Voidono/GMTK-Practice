class_name TimeBarUI
extends Control

@onready var time_bar: ProgressBar = $TimeBar
@onready var time_label: Label = $TimeLabel

@export var player_path: NodePath
var _countdown_health: CountdownHealth

func _ready() -> void:
	# Wait for the player and its CountdownHealth child to finish _ready().
	await get_tree().process_frame
	_bind_to_player()

func _process(_delta: float) -> void:
	# The signal updates the UI immediately; polling keeps it correct if the
	# player or its health component is recreated during gameplay.
	if not is_instance_valid(_countdown_health):
		_bind_to_player()
		return
	_on_health_changed(_countdown_health.current, _countdown_health.max_time)

func _bind_to_player() -> void:
	var player := get_node_or_null(player_path)
	if not player:
		return
	_countdown_health = player.get_node_or_null("CountdownHealth") as CountdownHealth
	if not _countdown_health:
		push_warning("TimeBarUI: the player has no CountdownHealth node.")
		return
	if not _countdown_health.health_changed.is_connected(_on_health_changed):
		_countdown_health.health_changed.connect(_on_health_changed)
	_on_health_changed(_countdown_health.current, _countdown_health.max_time)

func _on_health_changed(current: float, maximum: float) -> void:
	time_bar.max_value = maximum
	time_bar.value = current
	time_label.text = "%02d / %02d" % [ceili(current), ceili(maximum)]
