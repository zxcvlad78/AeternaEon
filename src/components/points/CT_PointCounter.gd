class_name CT_PointCounter extends Node

signal points_changed()
signal max_points_changed()

@export var root:Node

@export var points:float = 100.0 :
	set(val):
		points = clamp(points, 0.0, max_points)
		points_changed.emit()

@export var max_points:float = 100.0 :
	set(val):
		max_points = val
		max_points_changed.emit()

@export var point_bar_prefab: PackedScene = PointBar.get_default_prefab():
	set(val):
		point_bar_prefab = val
		
		if is_instance_valid(_point_bar_3d):
			_point_bar_3d.set_point_bar(point_bar_prefab)

var _point_bar_3d:PointBar3D

func _ready() -> void:
	if not root:
		root = get_parent()

	if _point_bar_3d:
		_point_bar_3d.free()
	
	_point_bar_3d = PointBar3D.get_default_prefab().instantiate() as PointBar3D
	if _point_bar_3d:
		_point_bar_3d.point_counter = self
		root.add_child.call_deferred(_point_bar_3d)
		
		_point_bar_3d.set_point_bar(point_bar_prefab)
	
		if root.has_method("get_unit_height"):
			_point_bar_3d.position.y = root.get_unit_height() + 0.025
	
	SimusNetVars.register(
		self,
		[
			"points",
			"max_points",
		],
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication()
	)
	
	SimusNetRPC.register(
		[
			_local_reset,
			_local_apply_diminish,
			_local_apply_replenish
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	if not is_instance_valid(root):
		return
	
	SD_ECS.append_to(root, self)


func reset() -> void:
	SimusNetRPC.invoke_on_server(_local_reset)

func apply_diminish(value:R_PointValue) -> void:
	SimusNetRPC.invoke_on_server(_local_apply_diminish, value)
func apply_replenish(value:R_PointValue) -> void:
	SimusNetRPC.invoke_on_server(_local_apply_replenish, value)

func _local_reset() -> void:
	points = max_points

func _local_apply_diminish(value:R_PointValue) -> void:
	points -= value.points
func _local_apply_replenish(value:R_PointValue) -> void:
	points -= value.points
