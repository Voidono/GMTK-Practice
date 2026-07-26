extends Button

signal closed

func _on_pressed() -> void:
	closed.emit()
	get_parent().queue_free()
	pass # Replace with function body.
