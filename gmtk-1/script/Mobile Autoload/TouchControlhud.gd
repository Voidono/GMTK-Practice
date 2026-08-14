extends CanvasLayer
## Responsive thumb-zone layout for the joystick and action buttons. Layout
## is calculated from the visible viewport, so it works on phones, tablets,
## portrait embeds, and resized browser windows without scene edits.

@onready var joystick: VirtualJoystick = $VirtualJoystick
@onready var slash_button: TouchButton = $SlashButton
@onready var dash_button: TouchButton = $DashButton
@onready var slow_button: TouchButton = $SlowButton

func _ready() -> void:
	visible = ControlScheme.is_touch
	ControlScheme.mode_changed.connect(_on_mode_changed)
	get_viewport().size_changed.connect(_layout_controls)
	call_deferred("_layout_controls")

func _on_mode_changed(is_touch: bool) -> void:
	visible = is_touch
	if is_touch:
		call_deferred("_layout_controls")

func _layout_controls() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var scale := clampf(minf(viewport_size.x / 960.0, viewport_size.y / 540.0), 0.72, 1.25)
	var margin := 18.0 * scale

	var joystick_size := 148.0 * scale
	joystick.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	joystick.position = Vector2(margin, viewport_size.y - margin - joystick_size)
	joystick.size = Vector2.ONE * joystick_size
	joystick.joystick_size = joystick_size
	joystick.tip_size = 56.0 * scale
	joystick.mouse_filter = Control.MOUSE_FILTER_STOP

	var primary_radius := 58.0 * scale
	var secondary_radius := 48.0 * scale
	var gap := 12.0 * scale
	var slash_position := Vector2(viewport_size.x - margin - primary_radius * 2.0, viewport_size.y - margin - primary_radius * 2.0)
	_place_button(slash_button, slash_position, primary_radius)
	_place_button(dash_button, Vector2(slash_position.x - secondary_radius * 2.0 - gap, slash_position.y + primary_radius - secondary_radius), secondary_radius)
	_place_button(slow_button, Vector2(slash_position.x + primary_radius - secondary_radius, slash_position.y - secondary_radius * 2.0 - gap), secondary_radius)

func _place_button(button: TouchButton, position: Vector2, button_radius: float) -> void:
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	button.position = position
	button.size = Vector2.ONE * button_radius * 2.0
	button.radius = button_radius
	button.queue_redraw()
