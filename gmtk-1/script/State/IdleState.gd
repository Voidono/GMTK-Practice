class_name PlayerStateIdle
extends State
## Node name in the tree must be "Idle".
## NOTE: AutoAimShoot now fires continuously (with or without an enemy
## present), so it no longer transitions back here automatically. This
## state is kept around only if you want somewhere to send the player
## manually (e.g. transitioned.emit(self, "idle") on death/cutscene/etc).
## If you don't need that, just set the StateMachine's initial_state to
## AutoAimShoot directly and you can delete this file.

var player: Player

func enter() -> void:
	player = state_machine.get_parent() as Player
