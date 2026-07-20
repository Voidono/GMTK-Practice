class_name Health
extends Node
## Reusable on anything that can take damage. Attach as a child node,
## give it max_health, and forward take_damage() calls to it.

signal health_changed(current: int, max: int)
signal died

@export var max_health: int = 30

var current: int

func _ready() -> void:
	current = max_health

func take_damage(amount: int) -> void:
	if current <= 0:
		return

	current = max(current - amount, 0)
	health_changed.emit(current, max_health)

	if current <= 0:
		died.emit()
