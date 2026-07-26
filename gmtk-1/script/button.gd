extends Button
signal closed

func _on_pressed() -> void:
	closed.emit()
	owner.queue_free() 
