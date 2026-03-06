class_name Controllable extends Node


var unit:BaseUnit
@export var can_controll:bool = true

var owner_id:int = 1 ##Owner player peer id

var controlled:bool = false ##Is controlled by somebody
var controlled_by_id:int = 1 ## The player who controls this unit

var is_rotating:bool = false
var move_target_reached:bool = true

func _ready() -> void:
	unit = get_parent()
	unit.input_event.connect(on_input_event)
	
	if is_instance_valid(Player.get_local_instance()):
		Player.get_local_instance().action_cancel.connect(stop)
	
	unit.ready.connect(
		func():
			unit.navigation_agent.target_reached.connect(stop)
	)


func on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if SD_Network.is_authority(self):
		if is_instance_valid(unit) and is_instance_valid(Player.get_local_instance()):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						Player.get_local_instance().target_picked.emit(unit)

func goto(pos:Vector3) -> void:
	#unit.attack_component.cancel_attack()
	move_target_reached = false
	unit.state_machine.switch_by_name("moving")
	unit.navigation_agent.set_target_position(pos)

func goto_target(target:Variant) -> void:
	if target is Node3D:
		goto(target.global_position)
	elif target is Vector3:
		goto(target)

func stop() -> void:
	move_target_reached = true
	unit.state_machine.switch_by_name("idle")

func _physics_process(delta: float) -> void:
	if not move_target_reached and unit.navigation_agent.target_position:
		var destination: Vector3 = unit.navigation_agent.get_next_path_position()
		var local_destination: Vector3 = destination - unit.global_position
		var direction: Vector3 = local_destination.normalized()
		
		var flat_direction = Vector3(direction.x, 0, direction.z).normalized()
		var current_forward = -unit.global_transform.basis.z
		var flat_forward = Vector3(current_forward.x, 0, current_forward.z).normalized()
		
		rotate_towards_direction(flat_direction, delta)
		
		var angle_to_target = flat_forward.angle_to(flat_direction)
		if angle_to_target < 1.5:
			is_rotating = false
		
		if not is_rotating:
			unit.velocity = direction * unit.get_movespeed()
			unit.move_and_slide()



func rotate_towards_direction(target_direction: Vector3, delta: float) -> void:
	is_rotating = true
	var current_transform = unit.global_transform
	var current_forward = -current_transform.basis.z
	
	var flat_current = Vector3(current_forward.x, 0, current_forward.z).normalized()
	var flat_target = Vector3(target_direction.x, 0, target_direction.z).normalized()
	
	var rotation_amount = unit.rotation_speed * delta
	var new_direction = flat_current.slerp(flat_target, rotation_amount).normalized()
	
	if new_direction.length() > 0.001:
		var look_at_point = unit.global_position + new_direction
		unit.look_at(look_at_point, Vector3.UP)
