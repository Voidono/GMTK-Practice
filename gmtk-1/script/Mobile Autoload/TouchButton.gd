class_name TouchButton
extends Control
## One reusable script for all 3 buttons (slash/dash/time_slow) -
## configure action_name per instance rather than writing 3 separate
## scripts. Input.action_press()/action_release() make a touch on this
## indistinguishable from a real key/mouse press to everything else in
## the game - CombatState reads Input.is_action_just_pressed(slash_
## action) exactly the same either way, no changes needed there.
##
## Self-drawn (no texture assets needed), same technique as
## VirtualJoystick.

@export var action_name: StringName
@export var label_text: String = ""
@export var radius: float = 60.0
@export var idle_color: Color = Color(1, 1, 1, 0.2)
@export var pressed_color: Color = Color(1, 1, 1, 0.5)

var _touch_index: int = -1
var _mouse_active := false
var _is_pressed: bool = false

func _input(event: InputEvent) -> void:
	if not ControlScheme.is_touch or not visible:
		return

	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _touch_index != -1:
			return
		var from_center := event.position - (global_position + size * 0.5)
		if from_center.length() <= radius:
			_touch_index = event.index
			_press()
	elif event.index == _touch_index:
		_touch_index = -1
		_release()

func _handle_mouse(event: InputEventMouseButton) -> void:
	if event.pressed and not _mouse_active and _touch_index == -1:
		var from_center := event.position - (global_position + size * 0.5)
		if from_center.length() <= radius:
			_mouse_active = true
			_press()
	elif not event.pressed and _mouse_active:
		_mouse_active = false
		_release()

func _press() -> void:
	_is_pressed = true
	if action_name == &"slash" or action_name == &"dash":
		ControlScheme.request_mobile_action(action_name)
	Input.action_press(action_name)
	queue_redraw()

func _release() -> void:
	_is_pressed = false
	Input.action_release(action_name)
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var fill := pressed_color if _is_pressed else idle_color
	draw_circle(center + Vector2(0, radius * 0.08), radius, Color(0.0, 0.0, 0.0, 0.35))
	draw_circle(center, radius, fill)
	draw_circle(center, radius * 0.72, Color(fill.r, fill.g, fill.b, fill.a * 0.55))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.9, 0.97, 1.0, 0.7), maxf(1.5, radius * 0.035), true)

	if label_text != "":
		var font := ThemeDB.fallback_font
		var font_size := roundi(radius * 0.34)
		var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := center - text_size / 2.0
		text_pos.y += text_size.y * 0.75
		draw_string(font, text_pos + Vector2(1.0, 2.0), label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.0, 0.0, 0.0, 0.7))
		draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
