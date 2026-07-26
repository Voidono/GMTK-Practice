extends Node2D

const GAME_SCENE_PATH := "res://screen/map1.tscn"



func _on_button_3_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_button_pressed() -> void:
	var result := get_tree().change_scene_to_file("res://screen/level selection.tscn")
	if result != OK:
		push_error("Menu: failed to open %s (error %d)." % [GAME_SCENE_PATH, result])


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://screen/setting menu.tscn")
	pass # Replace with function body.
