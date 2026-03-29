class_name PointBar3D extends Node3D

static func get_default_prefab() -> PackedScene:
	return preload("res://src/prefabs/point_bar/point_bar_3d.tscn")

var sub_viewport:SubViewport
var canvas_layer:CanvasLayer

var _point_bar:Control
var point_counter:CT_PointCounter

func _enter_tree() -> void:
	sub_viewport = get_node("SubViewport")
	canvas_layer = sub_viewport.get_node("CanvasLayer")

func set_point_bar(prefab:PackedScene) -> void:
	if not sub_viewport:
		sub_viewport = get_node_or_null("SubViewport")
	if not sub_viewport:
		return
	
	if not canvas_layer:
		canvas_layer = sub_viewport.get_node_or_null("CanvasLayer")
	if not canvas_layer:
		return
	
	if not point_counter:
		return
	if is_instance_valid(_point_bar):
		_point_bar.free()
	
	_point_bar = prefab.instantiate()
	_point_bar.set("point_counter", point_counter)
	
	canvas_layer.add_child(_point_bar)
