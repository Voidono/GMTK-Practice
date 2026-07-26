extends Control




func _on_chơi_lại_pressed() -> void:
	get_tree().change_scene_to_file("res://screen/map1.tscn")



func _on_quay_về_pressed() -> void:
	get_tree().change_scene_to_file("res://screen/menu.tscn")
