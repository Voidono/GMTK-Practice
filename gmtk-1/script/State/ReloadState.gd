class_name ReloadState
extends State
## Deliberately does nothing but wait. This is the payoff of using a
## real state machine: while this state is active, EngageState's
## physics_update() simply isn't running - no separate "is_reloading"
## boolean to check everywhere else in the code. Can't-fire-while-
## reloading is guaranteed structurally, not by convention.

@export var gun: Gun
@export var engage_state: State

func enter() -> void:
	gun.reloaded.connect(_on_reloaded)
	gun.start_reload()

func exit() -> void:
	gun.reloaded.disconnect(_on_reloaded)

func _on_reloaded() -> void:
	transition_requested.emit(engage_state)
