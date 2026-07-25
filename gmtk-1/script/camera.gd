extends Node2D

#load trước
const PAUSE_MENU_SCENE = preload("res://screen/gamemenu.tscn")
const SETTING_MENU = preload("res://screen/settinggame_menu.tscn")


func _on_button_pressed() -> void:
	open_pause_menu()
	pass # Replace with function body.

func open_pause_menu():
	var pause_menu = PAUSE_MENU_SCENE.instantiate()
	
	add_child(pause_menu)
	
	pause_menu.game_resumed.connect(_on_game_resumed)

func _on_game_resumed():
	print("Game đã tiếp tục bình thường!")

func _on_settings_pressed() -> void:
	var setting_menu = SETTING_MENU.instantiate()
	
	get_parent().add_child(setting_menu)
	
	if setting_menu.has_signal("closed"):
		setting_menu.closed.connect(_on_setting_closed)
	
	queue_free()

func _on_setting_closed():
	# Tạo lại Pause Menu
	var new_pause = PAUSE_MENU_SCENE.instantiate()
	get_parent().add_child(new_pause)
