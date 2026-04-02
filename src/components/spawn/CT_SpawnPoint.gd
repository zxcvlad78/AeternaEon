@tool
class_name CT_SpawnPoint extends Node3D

@export_tool_button("Update", "Breakpoint") var update_button = _update

var _name_label: Label3D
var _mesh_instance: MeshInstance3D

@export_group("Custom Settings", "custom")
@export var custom_name: StringName = "":
	set(val):
		custom_name = val
		_update()

@export var custom_mesh: Mesh = null:
	set(val):
		custom_mesh = val
		_update()

const DEFAULT_MESH = preload("uid://hw122wxa6yyl")

var reference_list:Array[CT_SpawnPoint]

func _init() -> void:
	visible = Engine.is_editor_hint()

func _setup_internal_nodes() -> void:
	_name_label = get_node_or_null("DebugLabel")
	if not _name_label:
		_name_label = Label3D.new()
		_name_label.name = "DebugLabel"
		_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(_name_label)

	_mesh_instance = get_node_or_null("DebugMesh")
	if not _mesh_instance:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "DebugMesh"
		_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_mesh_instance)

func append_to_reference_list() -> void:
	if multiplayer.is_server():
		if reference_list.has(self):
			return
		reference_list.append(self)

func erase_from_reference_list() -> void:
	if multiplayer.is_server():
		if not reference_list.has(self):
			return
		reference_list.erase(self)

func _enter_tree() -> void:
	append_to_reference_list()

func _exit_tree() -> void:
	erase_from_reference_list()

func get_spawn_name() -> StringName:
	if custom_name:
		return custom_name
	return name

func get_spawn_mesh() -> Mesh:
	if custom_mesh:
		return custom_mesh
	return DEFAULT_MESH

func _update() -> void:
	if not is_inside_tree(): return
	
	if _mesh_instance:
		_mesh_instance.mesh = get_spawn_mesh()
	
	if _name_label:
		_name_label.text = get_spawn_name()
		
		if _mesh_instance and _mesh_instance.mesh:
			var height = _mesh_instance.get_aabb().size.y
			_name_label.position.y = (height / 2.0) + 0.5
		else:
			_name_label.position.y = 1.0

func _spawn() -> void:
	pass

func spawn() -> void:
	if not multiplayer.is_server():
		return
	_spawn()

func _ready() -> void:
	_setup_internal_nodes()
	_update()
	
	
	if not Engine.is_editor_hint():
		SimusNetVars.register(self,
		[
		  "reference_list",
		], SimusNetVarConfig.new().flag_mode_server_only().flag_replication()
		)
