class_name Targeting
extends Node2D
## Drop this as a child anywhere under the character that needs it
## (it uses its own global_position, so parent it wherever you want
## "the search origin" to be - usually right on the character).
##
## Scans on an interval instead of every physics frame (cheaper, and
## still plenty responsive), and only emits when the target actually
## changes - not every scan - so listeners aren't spammed.

signal target_acquired(target: Node2D)
signal target_lost

@export var target_group: StringName = &"enemies"
@export var scan_interval: float = 0.15

var current_target: Node2D
var _scan_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = scan_interval
		_rescan()

func _rescan() -> void:
	var nearest := _find_nearest()

	if nearest == current_target:
		return

	current_target = nearest
	if current_target:
		target_acquired.emit(current_target)
	else:
		target_lost.emit()

func _find_nearest() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist_sq := INF

	for node in get_tree().get_nodes_in_group(target_group):
		if not is_instance_valid(node):
			continue
		var d := global_position.distance_squared_to(node.global_position)
		if d < nearest_dist_sq:
			nearest_dist_sq = d
			nearest = node

	return nearest
