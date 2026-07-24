class_name CombatState
extends State
## Rename target: FileSystem dock, right-click your old engage_state.gd
## -> Rename -> "combat_state.gd", then paste this content in. You
## didn't ask for this one specifically, but it had the same gun/reload
## style mismatch (file said "engage", class was CombatState) - fixing
## it too so nothing's left half-renamed.
##
## Default state: normal WASD movement, a manual slash on input aimed
## at the mouse, and the trigger into Dashing.

@export var player: Player
@export var slash_weapon: SlashWeapon
@export var dashing_state: State
@export var slash_action: StringName = &"slash"
@export var dash_action: StringName = &"dash"

func enter() -> void:
	# TEMPORARY - remove once dash is confirmed working
	print("dash action exists: ", InputMap.has_action(dash_action))
	print("dash action bindings: ", InputMap.action_get_events(dash_action))

	if not player:
		push_error("CombatState: 'Player' field is unassigned in the Inspector.")
	if not slash_weapon:
		push_error("CombatState: 'Slash Weapon' field is unassigned in the Inspector.")
	if not dashing_state:
		push_error("CombatState: 'Dashing State' field is unassigned in the Inspector.")

func physics_update(_delta: float) -> void:
	if not player:
		return

	player.velocity = player.input_vector * player.speed
	player.move_and_slide()

	if Input.is_action_just_pressed(slash_action):
		if slash_weapon:
			slash_weapon.swing(player.aim_direction)
		else:
			push_warning("CombatState: slash pressed but 'Slash Weapon' field is unassigned - nothing happens.")
	elif Input.is_action_just_pressed(dash_action):
		if dashing_state:
			transition_requested.emit(dashing_state)
		else:
			push_warning("CombatState: dash pressed but 'Dashing State' field is unassigned - nothing happens.")
