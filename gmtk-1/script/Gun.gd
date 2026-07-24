class_name MeleeWeapon
extends Marker2D
## Same file path as the old Gun script (avoids reattaching in the
## editor) - content fully replaced. Attach to a Marker2D positioned at
## the player's weapon origin. Spawns a SlashHitbox on command - no
## ammo, no cooldown baked in here, same "just do what it's told"
## philosophy Gun had after its own earlier simplification.

signal swung(hitbox: Node)

@export var hitbox_scene: PackedScene
@export var reach: float = 40.0  # how far in front of the player the hitbox spawns

func swing(direction: Vector2) -> void:
	if not hitbox_scene:
		push_warning("MeleeWeapon: no hitbox_scene assigned in the Inspector")
		return

	var hitbox := hitbox_scene.instantiate()
	get_tree().current_scene.add_child(hitbox)
	hitbox.global_position = global_position + direction * reach
	hitbox.rotation = direction.angle()
	swung.emit(hitbox)
