class_name Player extends Node3D

signal target_picked(target:BaseUnit)
signal current_unit_changed(unit_res:R_UnitProperties)
signal action_cancel()

@export var custom_ui:PackedScene
@onready var camera:Camera3D = get_node("Camera3D")


var pick_spell_target_mode:bool = false
var current_unit:BaseUnit : set = set_current_unit

#server only
static var instance_list:Array[Player] = []
#

static var instance:Player

func _enter_tree() -> void:
	instance = self
	
	_append_to_list(self)

func _exit_tree() -> void:
	if not instance_list.has(self):
		return
	instance_list.erase(self)

func _ready() -> void:
	target_picked.connect(_target_picked)
	
	var rpc_cfg:SimusNetRPCConfig = SimusNetRPCConfig.new()
	rpc_cfg.flag_mode_any_peer()
	
	SimusNetRPC.register(
		[
			
		],
		rpc_cfg
	)
	
	if not is_multiplayer_authority():
		return
	
	if custom_ui:
		var new_ui = custom_ui.instantiate()
		add_child(new_ui)

	if is_instance_valid(PlayerUI.instance):
		PlayerUI.instance.player = self


func _append_to_list(player:Player) -> void:
	if instance_list.has(player):
		return
	instance_list.append(player)

static func get_by_peer_id(id:int) -> Player:
	for inst in instance_list:
		if inst.get_multiplayer_authority() == id:
			return inst
	return null


func _target_picked(target:BaseUnit) -> void:
	if pick_spell_target_mode:
		current_unit.spell_container.pick_target(target)
	else:
		set_current_unit(target)

func set_current_unit(unit:BaseUnit) -> void:
	current_unit = unit
	current_unit_changed.emit(unit.unit_resource)

func cancel_unit_actions() -> void:
	current_unit.controllable.stop()
	current_unit.attack_component.cancel_attack()
	current_unit.spell_container.set_casting(false)

func _process(delta: float) -> void:
	if is_instance_valid(current_unit):
		if Input.is_action_just_pressed("cancel_action"):
			cancel_unit_actions()
		if Input.is_action_pressed("choose_current_unit"):
			camera.global_position.x = lerp(camera.global_position.x, current_unit.global_position.x + 2.85, delta * 10)
			camera.global_position.z = lerp(camera.global_position.z, current_unit.global_position.z - 2.0, delta * 10)
	
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	
	#region CAMERA_CONTROLS
	if get_window().has_focus() and is_mouse_in_window():
		if mouse_pos.x <= 1:
			move_left(delta)
		if mouse_pos.y <= 1:
			move_forward(delta)
		if mouse_pos.x >= screen_size.x-1:
			move_right(delta)
		if mouse_pos.y >= screen_size.y-1:
			move_backward(delta)
	
	if Input.is_action_pressed("camera_left"):
		move_left(delta)
	if Input.is_action_pressed("camera_right"):
		move_right(delta)
	if Input.is_action_pressed("camera_forward"):
		move_forward(delta)
	if Input.is_action_pressed("camera_backward"):
		move_backward(delta)
	#endregion

func move_left(delta:float) -> void:
	camera.global_position.x += delta * GameSettings.camera_speed
	camera.global_position.z += delta * GameSettings.camera_speed
func move_right(delta:float) -> void:
	camera.global_position.x -= delta * GameSettings.camera_speed
	camera.global_position.z -= delta * GameSettings.camera_speed
func move_forward(delta:float) -> void:
	camera.global_position.x -= delta * GameSettings.camera_speed
	camera.global_position.z += delta * GameSettings.camera_speed
func move_backward(delta:float) -> void:
	camera.global_position.x += delta * GameSettings.camera_speed
	camera.global_position.z -= delta * GameSettings.camera_speed

func is_mouse_in_window() -> bool:
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	var in_window:bool = not (mouse_pos.x < 0 or mouse_pos.y < 0 or mouse_pos.x > screen_size.x or mouse_pos.y > screen_size.y)
	return in_window

static func get_local_instance() -> Player:
	return instance
