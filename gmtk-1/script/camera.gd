extends Node2D

#load trước
const PAUSE_MENU_SCENE = preload("res://screen/gamemenu.tscn")



func _on_button_pressed() -> void:
	open_pause_menu()
	pass # Replace with function body.

func open_pause_menu():
	var pause_menu = PAUSE_MENU_SCENE.instantiate()
	
	add_child(pause_menu)
	
	pause_menu.game_resumed.connect(_on_game_resumed)

func _on_game_resumed():
	print("Game đã tiếp tục bình thường!")
