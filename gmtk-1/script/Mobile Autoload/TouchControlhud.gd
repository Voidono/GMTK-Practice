extends CanvasLayer
## Container for VirtualJoystick + the 3 TouchButtons. Shows/hides
## itself based on ControlScheme.is_touch - the one place that decides
## this, so individual controls don't each need their own visibility
## logic beyond the _input guards they already have.

func _ready() -> void:
	visible = ControlScheme.is_touch
	ControlScheme.mode_changed.connect(func(is_touch: bool) -> void: visible = is_touch)
