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

func _ready() -> void:
	is_touch = _detect_touch()
	mode_changed.emit(is_touch)

func _detect_touch() -> bool:
	if force_desktop_mode:
		return false
	if force_touch_mode:
		return true
	# "mobile" is Godot's export feature tag and is enabled for Android
	# and iOS builds. Do not use touchscreen availability here: a desktop
	# PC can have a touch display, but should still use the desktop HUD.
	return OS.has_feature("mobile")
