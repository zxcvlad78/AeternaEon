class_name CT_FreeOnDeath extends Node

@export var point_counter:CT_PointCounter

func _enter_tree() -> void:
	if not is_instance_valid(point_counter):
		return
	
	point_counter.points_changed.connect(_on_points_changed)

func _on_points_changed() -> void:
	if not is_instance_valid(point_counter):
		return
	if not is_instance_valid(point_counter.root):
		return
	
	if point_counter.points <= 0.0:
		point_counter.root.queue_free()
