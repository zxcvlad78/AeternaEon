@tool
class_name CT_SpawnPoint extends Node3D

@export_tool_button("Update", "Breakpoint") var update_button = _update

var _name_label:Label3D :
	set(val):
		if is_instance_valid(_name_label):
			_name_label.queue_free()
		_name_label = val
		_update()
		
		if _name_label:
			_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

var _mesh_instance:MeshInstance3D :
	set(val):
		if is_instance_valid(_mesh_instance):
			_mesh_instance.queue_free()
		_mesh_instance = val
		_update()
		
		if _mesh_instance:
			_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

@export_group("Custom Settings", "custom")
@export var custom_name:StringName = "" :
	set(val):
		custom_name = val
		_update()
@export var custom_mesh:Mesh = null :
	set(val):
		custom_mesh = val
		_update()

const DEFAULT_MESH = preload("uid://hw122wxa6yyl")

var reference_list:Array[CT_SpawnPoint]

func _init() -> void:
	visible = Engine.is_editor_hint()

func append_to_reference_list() -> void:
	if SimusNetConnection.is_server():
		if reference_list.has(self):
			return
		reference_list.append(self)

func erase_from_reference_list() -> void:
	if SimusNetConnection.is_server():
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
	if is_instance_valid(_name_label):
		_name_label.text = get_spawn_name()
		if is_instance_valid(_mesh_instance):
			var label_offset = (_mesh_instance.get_aabb().size.y / 2.0) + 0.5
			_name_label.position.y = label_offset
	if _mesh_instance:
		_mesh_instance.mesh = get_spawn_mesh()

func _spawn() -> void:
	pass

func spawn() -> void:
	if not multiplayer.is_server():
		return
	_spawn()

func _ready() -> void:
	_name_label = Label3D.new()
	add_child(_name_label)
	
	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)
	
	_update()
	
	if not Engine.is_editor_hint():
		SimusNetVars.register(self,
		[
		  "reference_list",
		], SimusNetVarConfig.new().flag_mode_server_only().flag_replication()
		)
