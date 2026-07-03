extends Node2D




func _on_button_3_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://screen/level selection.tscn")
	pass # Replace with function body.
