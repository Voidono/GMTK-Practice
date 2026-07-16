class_name Enemy
extends CharacterBody2D
## Scene tree expected:
## Enemy (CharacterBody2D)
##  - Sprite2D
##  - CollisionShape2D
## Automatically joins the "enemies" group on ready, which is how
## the player's auto-aim finds it and how bullets know to damage it.

@export var speed: float = 40.0
@export var max_health: int = 30

var health: int
var player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		var dir := (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
