class_name Enemy
extends CharacterBody2D

@export var health: Health

func _ready() -> void:
	add_to_group("enemies")
	health.died.connect(_on_died)

## Duck-typed entry point Bullet calls - forwards straight to Health.
func take_damage(amount: int) -> void:
	health.take_damage(amount)

func _on_died() -> void:
	queue_free()
