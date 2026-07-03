extends Control

@onready
var volume_slider = $HSlider # Thay $HSlider bằng đường dẫn tới node Slider của bạn

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	# Kết nối signal thông qua node slider
	volume_slider.value_changed.connect(_on_value_changed)

@export
var bus_name : String

var bus_index : int

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://screen/menu.tscn")
	pass # Replace with function body.
