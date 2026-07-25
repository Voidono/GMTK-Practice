class_name SlashWeapon
extends Marker2D
## Rename target: in Godot's FileSystem dock, right-click your old
## gun.gd -> Rename -> "slash_weapon.gd" (this auto-updates the script
## reference on whatever node has it attached), then paste this content
## in. Class renamed from MeleeWeapon to SlashWeapon to match.
##
## Attach to a Marker2D positioned at the player's weapon origin.
## Spawns a SlashHitbox on command - no ammo, no cooldown baked in
## here, just "do what it's told."

signal swung(hitbox: Node)

@export var hitbox_scene: PackedScene
@export var reach: float = 40.0  # how far in front of the player the hitbox spawns
@onready var slash_effect: AnimatedSprite2D = get_node_or_null("SlashEffect")
@onready var sword: Sprite2D = get_node_or_null("Sword")
@onready var swing_sound: AudioStreamPlayer2D = get_node_or_null("SwingSound")

func swing(direction: Vector2) -> void:
	_play_slash_effect()
	
	if swing_sound:
		swing_sound.play()
	
	if not hitbox_scene:
		push_warning("SlashWeapon: no hitbox_scene assigned in the Inspector")
		return

	var hitbox := hitbox_scene.instantiate()
	get_tree().current_scene.add_child(hitbox)
	hitbox.global_position = global_position + direction * reach
	hitbox.rotation = direction.angle()
	swung.emit(hitbox)

func _play_slash_effect() -> void:
	if not slash_effect:
		return
	
	slash_effect.show()
	slash_effect.play(&"slash")
	sword.hide()

func _on_slash_effect_animation_finished() -> void:
	if slash_effect:
		slash_effect.hide()
		sword.show()
