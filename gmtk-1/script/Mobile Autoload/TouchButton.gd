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
var _is_pressed: bool = false

func _input(event: InputEvent) -> void:
	if not ControlScheme.is_touch or not visible:
		return

	if event is InputEventScreenTouch:
		_handle_touch(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _touch_index != -1:
			return
		var from_center := event.position - (global_position + size * 0.5)
		if from_center.length() <= radius:
			_touch_index = event.index
			_is_pressed = true
			if action_name == &"slash" or action_name == &"dash":
				ControlScheme.request_mobile_action(action_name)
			Input.action_press(action_name)
			queue_redraw()
	elif event.index == _touch_index:
		_touch_index = -1
		_is_pressed = false
		Input.action_release(action_name)
		queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, radius, pressed_color if _is_pressed else idle_color)

	if label_text != "":
		var font := ThemeDB.fallback_font
		var font_size := 20
		var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := center - text_size / 2.0
		text_pos.y += text_size.y * 0.75
		draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
