extends Button

signal close 

func _on_pressed() -> void:
	close.emit()
	queue_free()
	pass # Replace with function body.
