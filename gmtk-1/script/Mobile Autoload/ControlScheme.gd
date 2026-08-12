extends Node
## AUTOLOAD - register this as a singleton named "ControlScheme" in
## Project Settings -> Autoload (see MOBILE.md for the exact steps,
## including why this needs to be saved as a .tscn rather than added
## as a bare script, if you want the debug overrides below editable in
## the Inspector).
##
## The one place that decides touch vs desktop controls. Everything
## that cares - TouchControlsHUD's visibility, Player's movement/aim
## source - reads ControlScheme.is_touch instead of re-detecting.
## Determined once at startup; games don't switch input hardware mid-
## session in any way worth reacting to live.

signal mode_changed(is_touch: bool)

## Debug overrides for testing in the editor, where OS.has_feature
## ("mobile") is always false and there's usually no touchscreen.
@export var force_touch_mode: bool = false
@export var force_desktop_mode: bool = false

var is_touch: bool = false
var _mobile_action_requests: Dictionary = {}

func _ready() -> void:
	is_touch = _detect_touch()
	mode_changed.emit(is_touch)

func _detect_touch() -> bool:
	if force_desktop_mode:
		return false
	if force_touch_mode:
		return true
	# Native Android/iOS exports use "mobile". A Web export is tagged as
	# "web" instead, even when it is opened on a phone, so check its host
	# platform tags as well. Do not use touchscreen availability here: a
	# desktop PC can have a touch display but should retain desktop controls.
	return OS.has_feature("mobile") \
		or OS.has_feature("web_android") \
		or OS.has_feature("web_ios")

## DebugTools uses this to simulate phone controls in the editor without
## changing the automatic device detection used by normal builds.
func debug_set_touch_mode(touch_mode: bool) -> void:
	force_touch_mode = touch_mode
	force_desktop_mode = not touch_mode
	is_touch = _detect_touch()
	mode_changed.emit(is_touch)

## TouchButtons call this for one-shot actions (slash and dash). This keeps
## browser touch-to-mouse emulation from firing attacks outside the buttons.
func request_mobile_action(action_name: StringName) -> void:
	_mobile_action_requests[action_name] = true

func consume_mobile_action(action_name: StringName) -> bool:
	if not _mobile_action_requests.get(action_name, false):
		return false
	_mobile_action_requests.erase(action_name)
	return true
