class_name PlayerCamera extends Node3D

signal unit_selected(unit:Unit)
signal point_selected(pos:Vector3)

var camera:Camera3D
@export var camera_rotation:Vector3 = Vector3(-51.0, 120.0, 0.0)

var target_select_mode:R_Spell.TargetType = R_Spell.TargetType.NO_TARGET :
	set(val):
		target_select_mode = val
		

static var ref_list:Array[PlayerCamera]
static func find_by_peer(peer_id:int) -> PlayerCamera:
	for ref in ref_list:
		if ref.get_multiplayer_authority() == peer_id:
			return ref
	return null

static var instance:PlayerCamera
static func i() -> PlayerCamera:
	return instance

var selected_units:Array[Unit]

func _enter_tree() -> void:
	if multiplayer.is_server():
		if not ref_list.has(self):
			ref_list.append(self)
	
	if not is_multiplayer_authority():
		return
	
	camera = get_or_create_camera()
	if not instance:
		instance = self

func _exit_tree() -> void:
	if multiplayer.is_server():
		if ref_list.has(self):
			ref_list.erase(self)

func _ready() -> void:
	SimusNetRPC.register(
		[
			_local_select_unit,
			_local_select_point,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	SimusNetVars.register(
		self,
		["ref_list"],
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication()
	)

func _local_select_unit(unit:Unit) -> void:
	if target_select_mode == R_Spell.TargetType.NO_TARGET:
		selected_units.clear()
		selected_units.append(unit)
	unit_selected.emit(unit)
func select_unit(unit:Unit) -> void:
	SimusNetRPC.invoke_all(_local_select_unit, unit)

func _local_select_point(pos:Vector3) -> void:
	point_selected.emit(pos)
func select_point(pos:Vector3) -> void:
	SimusNetRPC.invoke_all(_local_select_point, pos)

func get_main_unit() -> Unit:
	if selected_units.is_empty():
		return null
	return selected_units.front()

func get_or_create_camera() -> Camera3D:
	for c in get_children():
		if c is Camera3D:
			return c
	
	var new_cam:Camera3D = Camera3D.new()
	add_child(new_cam)
	new_cam.rotation_degrees = camera_rotation
	
	return new_cam

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	
	if get_window().has_focus() and is_mouse_in_window(viewport, screen_size, mouse_pos):
		if mouse_pos.x <= 1:
			move_left(delta)
		if mouse_pos.y <= 1:
			move_forward(delta)
		if mouse_pos.x >= screen_size.x-1:
			move_right(delta)
		if mouse_pos.y >= screen_size.y-1:
			move_backward(delta)
	
	if Input.is_action_pressed("move_camera_left"):
		move_left(delta)
	if Input.is_action_pressed("move_camera_right"):
		move_right(delta)
	if Input.is_action_pressed("move_camera_forward"):
		move_forward(delta)
	if Input.is_action_pressed("move_camera_backward"):
		move_backward(delta)

func move_left(delta:float) -> void:
	camera.global_position.x += delta * 5.0
	camera.global_position.z += delta * 5.0
func move_right(delta:float) -> void:
	camera.global_position.x -= delta * 5.0
	camera.global_position.z -= delta * 5.0
func move_forward(delta:float) -> void:
	camera.global_position.x -= delta * 5.0
	camera.global_position.z += delta * 5.0
func move_backward(delta:float) -> void:
	camera.global_position.x += delta * 5.0
	camera.global_position.z -= delta * 5.0

func is_mouse_in_window(viewport:Viewport = null, mouse_pos:Vector2 = Vector2.ZERO, screen_size:Vector2 = Vector2.ZERO) -> bool:
	if !viewport:
		viewport = get_viewport()
	if !screen_size:
		screen_size = viewport.get_visible_rect().size
	if !mouse_pos:
		mouse_pos = viewport.get_mouse_position()
	
	var in_window:bool = not (mouse_pos.x < 0 or mouse_pos.y < 0 or mouse_pos.x > screen_size.x or mouse_pos.y > screen_size.y)
	return in_window
