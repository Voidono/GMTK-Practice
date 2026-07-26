extends Control

const SETTING_MENU = preload("res://screen/layer screen/settinggame_menu.tscn")
const PAUSE_MENU_SCENE = preload("res://screen/layer screen/gamemenu.tscn")

signal game_resumed

func _ready():
	get_tree().paused = true

func resume():
	get_tree().paused = false
	game_resumed.emit()
	queue_free()

func _on_resume_pressed() -> void:
	resume()

func _on_settings_pressed() -> void:
	var setting_menu = SETTING_MENU.instantiate()
	get_parent().add_child(setting_menu)

	if setting_menu.has_signal("closed"):
		setting_menu.closed.connect(_on_setting_closed)

	hide()  # was: queue_free()

func _on_setting_closed() -> void:
	show()
func _on_menu_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://screen/level selection.tscn")
