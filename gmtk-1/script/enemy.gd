class_name Enemy
extends CharacterBody2D

const SOUL_PICKUP_SCENE := preload("res://screen/Gameplay/SoulPickup.tscn")
const MONSTER_STEP := preload("res://sound track/monster step.mp3")
const BOSS_PUNCH := preload("res://sound track/punch.mp3")
const BOSS_GUN := preload("res://sound track/slime gun.mp3")

@export var health: Health
@export var move_speed: float = 40.0
@export var melee_range: float = 32.0
@export var melee_damage: int = 8
@export var melee_cooldown: float = 1.0
@export var immune_to_time_stop: bool = false
@export var is_boss: bool = false
@export var projectile_scene: PackedScene
@export var spawned_slime_scene: PackedScene
@export var projectile_range: float = 260.0
@export var projectile_cooldown: float = 2.5
@export var knockback_distance: float = 22.0
@export var knockback_duration: float = 0.14
@export var hit_animation_duration: float = 0.30
@export var soul_value: float = 7.0

@onready var character_sprite: AnimatedSprite2D = $AnimatedSprite2D
var _melee_timer := 0.0
var _projectile_timer := 0.0
var _damage_timer := 0.0
var _knockback_timer := 0.0
var _knockback_velocity := Vector2.ZERO
var _projectile_pending := false
var _pending_projectile_direction := Vector2.RIGHT
var _facing_left := false
var _movement_sound: AudioStreamPlayer2D
var _step_cooldown := 0.0

func _ready() -> void:
	add_to_group("enemies")
	if health:
		health.died.connect(_on_died)
	else:
		push_error("Enemy '%s': Health field is unassigned in the Inspector." % name)
	var state_machine := get_node_or_null("StateMachine")
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_DISABLED
	character_sprite.animation_finished.connect(_on_character_sprite_animation_finished)
	_movement_sound = AudioStreamPlayer2D.new()
	_movement_sound.stream = MONSTER_STEP
	_movement_sound.finished.connect(_on_movement_sound_finished)
	add_child(_movement_sound)

func take_damage(amount: int) -> void:
	if health:
		_start_hit_reaction()
		AudioManager.play_enemy_hurt(soul_value >= 12.0 and not is_boss)
		health.take_damage(amount)

func _physics_process(delta: float) -> void:
	if _damage_timer > 0.0:
		_damage_timer -= delta
		if _knockback_timer > 0.0:
			_knockback_timer -= delta
			velocity = _knockback_velocity
			move_and_slide()
		else:
			velocity = Vector2.ZERO
		if _damage_timer <= 0.0:
			_knockback_velocity = Vector2.ZERO
		return
	if _projectile_pending:
		velocity = Vector2.ZERO
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return

	var time_compensation := 1.0 / Engine.time_scale if immune_to_time_stop and Engine.time_scale > 0.0 else 1.0
	var combat_delta := delta * time_compensation
	_melee_timer = maxf(_melee_timer - combat_delta, 0.0)
	_projectile_timer = maxf(_projectile_timer - combat_delta, 0.0)
	character_sprite.speed_scale = time_compensation

	var offset := player.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized()
	if direction.x != 0.0:
		_facing_left = direction.x < 0.0
	if distance <= melee_range:
		velocity = Vector2.ZERO
		_stop_movement_sound()
		_play_animation(&"Attack")
		if _melee_timer <= 0.0:
			player.take_damage(melee_damage)
			_melee_timer = melee_cooldown
			if is_boss:
				_play_one_shot(BOSS_PUNCH)
		return

	if is_boss and distance <= projectile_range and _projectile_timer <= 0.0:
		_stop_movement_sound()
		_begin_projectile_attack(direction)
		return
	velocity = direction * move_speed * time_compensation
	_update_movement_sound(combat_delta)
	_play_animation(&"Move")
	move_and_slide()

func _fire_projectile(direction: Vector2) -> void:
	if not projectile_scene:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + direction * melee_range
	projectile.target_group = &"player"
	projectile.spawn_scene = spawned_slime_scene
	projectile.set_direction(direction)

func _begin_projectile_attack(direction: Vector2) -> void:
	if not projectile_scene or _projectile_pending:
		return
	_projectile_pending = true
	_pending_projectile_direction = direction
	_projectile_timer = projectile_cooldown
	_play_one_shot(BOSS_GUN)
	_play_animation(&"Shoot")

func _on_character_sprite_animation_finished() -> void:
	if not _projectile_pending or character_sprite.animation != &"Shoot":
		return
	_projectile_pending = false
	_fire_projectile(_pending_projectile_direction)

func _play_animation(preferred: StringName) -> void:
	var directional_name := preferred
	if preferred == &"Move":
		directional_name = &"MoveLeft" if _facing_left else &"MoveRight"
		if not character_sprite.sprite_frames.has_animation(directional_name):
			directional_name = &"Move_left" if _facing_left else &"Move_right"
	elif preferred == &"Attack":
		directional_name = &"Attack_left" if _facing_left else &"Attack_right"
	if character_sprite.sprite_frames.has_animation(directional_name):
		character_sprite.flip_h = false
		character_sprite.play(directional_name)
		return
	if character_sprite.sprite_frames.has_animation(preferred):
		character_sprite.flip_h = _facing_left
		character_sprite.play(preferred)
		return
	for animation_name in character_sprite.sprite_frames.get_animation_names():
		if String(animation_name).begins_with(String(preferred)):
			character_sprite.play(animation_name)
			return
	if character_sprite.sprite_frames.has_animation(&"Idle"):
		character_sprite.play(&"Idle")

func _start_hit_reaction() -> void:
	_damage_timer = hit_animation_duration
	_knockback_timer = knockback_duration
	_knockback_velocity = Vector2.ZERO
	_projectile_pending = false
	_stop_movement_sound()
	_play_animation(&"Damaged")

	if is_boss:
		_knockback_timer = 0.0
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(player):
		var direction := (global_position - player.global_position).normalized()
		if direction != Vector2.ZERO and knockback_duration > 0.0:
			_knockback_velocity = direction * knockback_distance / knockback_duration

func _update_movement_sound(delta: float) -> void:
	# Slimes share a single jump voice, so a crowd never stacks the same
	# sound effect on top of itself.
	if not is_boss and soul_value < 12.0:
		AudioManager.play_slime_jump(global_position)
		return
	if is_boss:
		if not _movement_sound.playing:
			_movement_sound.play()
		return
	_step_cooldown = maxf(_step_cooldown - delta, 0.0)
	if _step_cooldown <= 0.0:
		_movement_sound.play()
		_step_cooldown = 0.45

func _stop_movement_sound() -> void:
	if _movement_sound:
		_movement_sound.stop()

func _on_movement_sound_finished() -> void:
	if is_boss and velocity != Vector2.ZERO and not _projectile_pending and _damage_timer <= 0.0:
		_movement_sound.play()

func _play_one_shot(stream: AudioStream) -> void:
	var sound := AudioStreamPlayer2D.new()
	sound.stream = stream
	add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()

func _on_died() -> void:
	_drop_soul()
	queue_free()

func _drop_soul() -> void:
	if soul_value <= 0.0:
		return
	var soul := SOUL_PICKUP_SCENE.instantiate() as Node2D
	get_tree().current_scene.add_child(soul)
	soul.global_position = global_position
	if soul.has_method("setup"):
		soul.setup(soul_value)
