class_name PlayerCamera extends Node3D

signal unit_selected(unit:Unit)

var camera:Camera3D
@export var camera_rotation:Vector3 = Vector3(-51.0, 120.0, 0.0)

static var instance:PlayerCamera
static func i() -> PlayerCamera:
	return instance

var selected_units:Array[Unit]

func _enter_tree() -> void:
	if not is_multiplayer_authority():
		return
	
	camera = get_or_create_camera()
	if not instance:
		instance = self

func select_unit(unit:Unit) -> void:
	#if selected_units.has(unit):
		#return
	
	selected_units.clear()
	selected_units.append(unit)
	
	unit_selected.emit()
	
	#print(selected_units)

func get_main_unit() -> Unit:
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
