class_name PlayerCamera extends Node3D

signal main_unit_changed()
signal unit_selected(unit:Unit)
signal point_selected(pos:Vector3)

signal on_order_hold_position()

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
var main_unit:Unit :
	set(val):
		main_unit = val
		main_unit_changed.emit()

func _enter_tree() -> void:
	if multiplayer.is_server():
		if not ref_list.has(self):
			ref_list.append(self)
	
	if not is_multiplayer_authority():
		return
	
	camera = get_or_create_camera()
	camera.current = true
	
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

func _update_selected_units() -> void:
	for unit in selected_units:
		unit.update.emit()

func _local_select_unit(unit:Unit) -> void:
	if target_select_mode == R_Spell.TargetType.NO_TARGET:
		selected_units.clear()
		selected_units.append(unit)
	unit_selected.emit(unit)
	main_unit = get_main_unit()

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

func _input(event: InputEvent) -> void:
	if SimusDev.ui.has_active_interface():
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		unit_selected.emit(null)
		point_selected.emit(null)
	
	if Input.is_action_just_pressed("hold_position"):
		var unit:Unit = get_main_unit()
		if unit:
			unit.unit_orders.hold_position()
	
	var shift_pressed = Input.is_action_pressed("shift")
	
	var result = _do_raycast()
	if result:
		if event.is_action_pressed("left_click"):
			if result.collider is Unit:
				select_unit(result.collider)
			else:
				select_point(result.position)
		if event.is_action_pressed("right_click"):
			if result.collider is Unit:
				for unit in selected_units:
					unit.ct_attack.order_task(result.collider, shift_pressed)
			else:
				for unit in selected_units:
					unit.ct_movement.order_task(result.position, shift_pressed)
					AE.show_goto_visual(result.position)

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_pressed("move_camera_left"):
		move_left(delta)
	if Input.is_action_pressed("move_camera_right"):
		move_right(delta)
	if Input.is_action_pressed("move_camera_forward"):
		move_forward(delta)
	if Input.is_action_pressed("move_camera_backward"):
		move_backward(delta)

func move_left(delta:float) -> void:
	global_position.x += delta * 5.0
	global_position.z += delta * 5.0
func move_right(delta:float) -> void:
	global_position.x -= delta * 5.0
	global_position.z -= delta * 5.0
func move_forward(delta:float) -> void:
	global_position.x -= delta * 5.0
	global_position.z += delta * 5.0
func move_backward(delta:float) -> void:
	global_position.x += delta * 5.0
	global_position.z -= delta * 5.0

func _do_raycast() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000.0
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	return space_state.intersect_ray(query)
