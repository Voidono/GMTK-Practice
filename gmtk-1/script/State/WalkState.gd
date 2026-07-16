extends State
class_name WalkState

func _physics_process(delta):
	var character = state_machine.get_parent()
	var direction = Input.get_axis("left", "right")
	var horizontal = Input.get_axis("up", "down")
	
	if direction and horizontal == 0:
		state_machine.change_state("IdleState")
		return
	character.velocity.x = direction * 200
	character.velocity.y = direction * 200
	character.move_and_slide
