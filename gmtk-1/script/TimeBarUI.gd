class_name TimeBarUI
extends Control

@onready var time_bar: ProgressBar = $TimeBar
@onready var time_label: Label = $TimeLabel

var _countdown_health: CountdownHealth

func _ready() -> void:
	call_deferred("_bind_to_player")

func _bind_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("TimeBarUI: no player was found.")
		return
	_countdown_health = player.get_node_or_null("CountdownHealth") as CountdownHealth
	if not _countdown_health:
		push_warning("TimeBarUI: the player has no CountdownHealth node.")
		return
	_countdown_health.health_changed.connect(_on_health_changed)
	_on_health_changed(_countdown_health.current, _countdown_health.max_time)

func _on_health_changed(current: float, maximum: float) -> void:
	time_bar.max_value = maximum
	time_bar.value = current
	time_label.text = "%02d / %02d" % [ceili(current), ceili(maximum)]
