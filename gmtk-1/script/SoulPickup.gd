class_name SoulPickup
extends Node2D

@export var pickup_range: float = 32.0
@export var lifetime: float = 15.0

var value: float = 7.0
var _age := 0.0
var _base_y := 0.0

func _ready() -> void:
	_base_y = position.y

func setup(amount: float) -> void:
	value = amount
	_base_y = position.y

func _physics_process(delta: float) -> void:
	_age += delta
	position.y = _base_y + sin(_age * 5.0) * 2.0
	if _age >= lifetime:
		queue_free()
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(player) and global_position.distance_to(player.global_position) <= pickup_range:
		if player.has_method("collect_soul"):
			player.collect_soul(value)
		queue_free()
