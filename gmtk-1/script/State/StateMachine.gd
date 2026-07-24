class_name StateMachine extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.transition_requested.connect(_on_transition_requested)
		
	if initial_state:
		change_state(initial_state.name.to_lower())
			
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _on_transition_requested(next_state: State) -> void:
	if next_state:
		change_state(next_state.name)

func change_state(new_state_name) -> void:
		if current_state:
			current_state.exit()
		
		current_state = states.get(new_state_name.to_lower())
		
		if current_state:
			current_state.enter()
