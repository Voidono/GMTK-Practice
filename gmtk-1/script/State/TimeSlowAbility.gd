class_name TimeSlowAbility
extends Node
## Standalone background component - NOT a Player state. You can still
## move/dash/slash while this is active, so it's a modifier running
## alongside whatever state Player is in, same pattern as EnemySpawner.
##
## Uses Engine.time_scale globally, which automatically slows every
## _process/_physics_process delta in the game (enemies, EnemySpawner's
## timer, everything) with zero changes needed to those scripts. The
## player stays fast via Player.move()/get_real_delta()'s built-in
## compensation - that split is what actually sells "I got faster than
## everything else" instead of "the game got choppy."
##
## The charge meter drains/regens in REAL seconds (see get_real_delta
## below) - holding it for 3 seconds always costs 3 real-world seconds
## of your time, regardless of how slow slow_scale makes everything
## else feel.
##
## NOTE ON A TRUE FULL STOP: Engine.time_scale can't actually reach
## exactly 0.0 while keeping the player compensated - the compensation
## trick divides by time_scale, and dividing by zero is undefined (the
## player would freeze along with everything else, since velocity
## times a zero timestep is always zero no matter how large the
## velocity is scaled). For a "the world basically stops" feel, use a
## very small slow_scale (e.g. 0.02-0.05) instead of 0. A LITERAL
## complete stop where enemies are 100% frozen and the player pays zero
## simulation cost is possible, but needs a different architecture
## (selectively freezing enemy StateMachines rather than a global
## time_scale) - worth building later if this doesn't feel extreme
## enough on its own.

signal activated
signal deactivated
signal charge_changed(current: float, max: float)

@export var activate_action: StringName = &"time_slow"
@export var slow_scale: float = 0.25              # how slow the world gets (1.0 = normal, lower = slower)
@export var max_charge: float = 3.0                # seconds of real-world hold time available
@export var regen_rate: float = 1.0                 # charge units regained per real second while inactive
@export var min_charge_to_activate: float = 0.2      # can't trigger on fumes

var current_charge: float
var is_active: bool = false

func _ready() -> void:
	current_charge = max_charge

func _exit_tree() -> void:
	if is_active:
		Engine.time_scale = 1.0

func _process(delta: float) -> void:
	var real_delta := get_real_delta(delta)
	var wants_active := Input.is_action_pressed(activate_action)

	if wants_active and not is_active and current_charge >= min_charge_to_activate:
		_activate()
	elif is_active and (not wants_active or current_charge <= 0.0):
		_deactivate()

	if is_active:
		current_charge = maxf(current_charge - real_delta, 0.0)
		charge_changed.emit(current_charge, max_charge)
		if current_charge <= 0.0:
			_deactivate()
	elif current_charge < max_charge:
		current_charge = minf(current_charge + real_delta * regen_rate, max_charge)
		charge_changed.emit(current_charge, max_charge)

func _activate() -> void:
	is_active = true
	Engine.time_scale = slow_scale
	activated.emit()

func _deactivate() -> void:
	is_active = false
	Engine.time_scale = 1.0
	deactivated.emit()

## Same trick as Player.get_real_delta() - kept as its own copy here
## rather than depending on Player, since this component doesn't
## otherwise need to know anything about Player's structure at all.
func get_real_delta(scaled_delta: float) -> float:
	return scaled_delta / Engine.time_scale if Engine.time_scale > 0.0 else scaled_delta
