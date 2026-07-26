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
@export var combo_reset_time: float = 1.25
@onready var slash_effect: AnimatedSprite2D = get_node_or_null("SlashEffect")
@onready var sword: Sprite2D = get_node_or_null("Sword")

var _combo_step := 0
var _last_swing_time := -INF
var _time_stop_active := false
var _attack_in_progress := false

func set_time_stop_active(active: bool) -> void:
	_time_stop_active = active
	_set_effect_real_time_speed()

func swing(direction: Vector2) -> bool:
	if _attack_in_progress:
		return false

	var now := Time.get_ticks_msec() * 0.001
	if now - _last_swing_time > combo_reset_time:
		_combo_step = 0

	_combo_step = (_combo_step % 3) + 1
	_last_swing_time = now
	_play_slash_effect(_combo_step)

	if not hitbox_scene:
		push_warning("SlashWeapon: no hitbox_scene assigned in the Inspector")
		return false

	var hitbox: SlashHitbox = hitbox_scene.instantiate()
	hitbox.configure(_combo_step, direction)
	hitbox.global_position = global_position
	get_tree().current_scene.add_child(hitbox)
	swung.emit(hitbox)
	return true

func _play_slash_effect(combo_step: int) -> void:
	if not slash_effect:
		return
	
	_attack_in_progress = true
	_set_effect_real_time_speed()
	slash_effect.show()
	var animation_name := StringName("slash_time_stop_%d" % combo_step) if _time_stop_active else StringName("slash_%d" % combo_step)
	slash_effect.play(animation_name)
	sword.hide()

func _set_effect_real_time_speed() -> void:
	if slash_effect:
		# Reapply before every swing so the final EF combo never inherits
		# the slowed global time scale.
		slash_effect.speed_scale = 1.0 / Engine.time_scale if _time_stop_active and Engine.time_scale > 0.0 else 1.0

func _on_slash_effect_animation_finished() -> void:
	_attack_in_progress = false
	if slash_effect:
		slash_effect.hide()
		sword.show()
