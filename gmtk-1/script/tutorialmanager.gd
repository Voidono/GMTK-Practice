extends Node

@onready var label = $TutorialLabel
@onready var timer = $TutorialTimer

var instructions = [
	"1: Move with WASD",
	"2: Press Space to dash, Press m1 to slash",
    "3: Kill enemy and pick up souls to continue game."
]
var current_index = 0

func _ready():
	timer.wait_time = 5.0  # seconds per instruction (use 20.0 if you prefer)
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	
	label.text = instructions[current_index]
	timer.start()

func _on_timer_timeout():
	current_index += 1
	if current_index >= instructions.size():
		timer.stop()
		label.text = ""  # or hide(), or leave the last instruction visible
		return
	label.text = instructions[current_index]
