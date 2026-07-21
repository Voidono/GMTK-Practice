extends Control


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
	print("Ra menu mà chỉnh")

func _on_menu_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://screen/level selection.tscn")
