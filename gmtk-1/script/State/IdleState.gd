extends State
class_name IdleState

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		state_machine.change_state("WalkState")
	pass
