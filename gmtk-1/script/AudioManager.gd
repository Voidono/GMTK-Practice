extends Node

const MENU_MUSIC := preload("res://sound track/A Dark Day Preview.mp3")
const MAP_MUSIC := preload("res://sound track/Battle Approaching Low Intensity Preview.mp3")
const VICTORY_MUSIC := preload("res://sound track/Victory Sound Effect - Der Test (youtube).mp3")
const LOSING_HORN := preload("res://sound track/The Price is Right Losing Horn - Sound Effect (HD) - Gaming Sound FX (youtube) (1).mp3")
const CLICK := preload("res://sound track/click.mp3")
const SLASH := preload("res://sound track/player/tieesng chém.mp3")
const SLIME_HURT := preload("res://sound track/slime/slime slashed.mp3")
const BADGER_HURT := preload("res://sound track/bị chém.mp3")
const PLAYER_STEP := preload("res://sound track/player/step.mp3")
const SLIME_JUMP := preload("res://sound track/slime/slimejump.mp3")

var _music: AudioStreamPlayer
var _effects: AudioStreamPlayer
var _slash: AudioStreamPlayer
var _last_scene_path := ""
var _last_hurt_time := -INF
var _slime_jump: AudioStreamPlayer2D

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_effects = AudioStreamPlayer.new()
	_slash = AudioStreamPlayer.new()
	add_child(_music)
	add_child(_effects)
	add_child(_slash)
	get_tree().node_added.connect(_on_node_added)
	call_deferred("_connect_existing_buttons")

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	var scene_path := scene.scene_file_path if scene else ""
	if scene_path != _last_scene_path:
		_last_scene_path = scene_path
		_set_scene_music(scene_path)

func play_slash() -> void:
	if not _slash.playing:
		_slash.stream = SLASH
		_slash.play()

func play_enemy_hurt(is_badger: bool) -> void:
	var now := Time.get_ticks_msec() * 0.001
	if now - _last_hurt_time < 0.12:
		return
	_last_hurt_time = now
	_play_effect(BADGER_HURT if is_badger else SLIME_HURT)

func play_player_step(position: Vector2) -> void:
	var step := AudioStreamPlayer2D.new()
	step.stream = PLAYER_STEP
	step.global_position = position
	get_tree().current_scene.add_child(step)
	step.finished.connect(step.queue_free)
	step.play()

func play_slime_jump(position: Vector2) -> void:
	if is_instance_valid(_slime_jump) and _slime_jump.playing:
		return
	_slime_jump = AudioStreamPlayer2D.new()
	_slime_jump.stream = SLIME_JUMP
	_slime_jump.global_position = position
	get_tree().current_scene.add_child(_slime_jump)
	_slime_jump.finished.connect(_slime_jump.queue_free)
	_slime_jump.play()

func _set_scene_music(scene_path: String) -> void:
	var track: AudioStream = null
	var should_loop := false
	if scene_path.ends_with("/menu.tscn"):
		track = MENU_MUSIC
		should_loop = true
	elif scene_path.ends_with("/map1.tscn"):
		track = MAP_MUSIC
		should_loop = true
	elif scene_path.ends_with("/win_screen.tscn"):
		track = VICTORY_MUSIC
		should_loop = true
	elif scene_path.ends_with("/lose_screen.tscn"):
		track = LOSING_HORN
	if _music.stream == track:
		return
	_music.stop()
	_music.stream = track
	if track:
		if track is AudioStreamMP3:
			track.loop = should_loop
		_music.play()

func _play_effect(stream: AudioStream) -> void:
	_effects.stream = stream
	_effects.play()

func _connect_existing_buttons() -> void:
	_connect_buttons(get_tree().root)

func _connect_buttons(node: Node) -> void:
	_on_node_added(node)
	for child in node.get_children():
		_connect_buttons(child)

func _on_node_added(node: Node) -> void:
	if node is BaseButton and not node.has_meta("click_sound_connected"):
		node.pressed.connect(_play_click)
		node.set_meta("click_sound_connected", true)

func _play_click() -> void:
	_play_effect(CLICK)
