extends CharacterBody2D


@export var enemy: Enemy
@export var speed: float = 40.0
@export var speed_multiplier: float = 3.0 # Hệ số nhân tốc độ khi phát hiện player

var current_speed: float

func _ready() -> void:
	current_speed = speed # Khởi tạo tốc độ ban đầu

func physics_update(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return

	var direction := (player.global_position - enemy.global_position).normalized()
	# Dùng current_speed thay vì speed cố định
	enemy.velocity = direction * current_speed 
	enemy.move_and_slide()

# Nối signal body_entered của Area2D vào hàm này
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_speed = speed * speed_multiplier # Nhân 3 tốc độ

# Nối signal body_exited của Area2D vào hàm này
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_speed = speed
