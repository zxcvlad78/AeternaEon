@tool
extends Node3D

@export_tool_button("Update") var upd_btn = _update

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var unit: Unit
@export var collision_shapes: Array[CollisionShape3D]

const CURRENT_COLOR = Color(0.5, 1.0, 0.0, 1.0)
const DEFAULT_COLOR = Color(1.0, 1.0, 1.0, 0.35)

var _is_player_connected: bool = false

func _ready() -> void:
	if not unit:
		return
	
	unit.update.connect(_update)
	_update()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_process(false)
		return

	var player = PlayerCamera.i()
	if is_instance_valid(player):
		if not player.main_unit_changed.is_connected(_update):
			player.main_unit_changed.connect(_update)
		
		_is_player_connected = true
		_update()
		set_process(false)

func _update() -> void:
	if not mesh_instance_3d:
		return
	
	if mesh_instance_3d.mesh is PlaneMesh:
		if not mesh_instance_3d.mesh.is_local_to_scene():
			mesh_instance_3d.mesh = mesh_instance_3d.mesh.duplicate()
		
		var r = _get_radius()
		mesh_instance_3d.mesh.size = Vector2(r * 2, r * 2)
	
	var mat = mesh_instance_3d.get_surface_override_material(0)
	if not mat:
		var base_mat = mesh_instance_3d.get_active_material(0)
		if base_mat:
			mat = base_mat.duplicate()
			mesh_instance_3d.set_surface_override_material(0, mat)
	
	if not mat is ShaderMaterial:
		return
	
	var player = PlayerCamera.i()
	var target_color = DEFAULT_COLOR
	
	if is_instance_valid(player) and player.get_main_unit() == unit:
		target_color = CURRENT_COLOR
	
	mat.set_shader_parameter("color", target_color)

func _get_radius() -> float:
	var radii = collision_shapes.filter(func(c): return c.shape is CylinderShape3D).map(func(c): return c.shape.radius)
	return radii.max() if not radii.is_empty() else 0.5
