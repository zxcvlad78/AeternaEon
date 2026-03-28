class_name CT_Movement extends Node

@export var unit: Unit
@onready var nav_agent: NavigationAgent3D = NavigationAgent3D.new()

var is_rotating: bool = false
var move_target_reached: bool = true
var current_target_node: Node3D = null

func _enter_tree() -> void:
	if not is_instance_valid(unit): return
	SD_ECS.append_to(unit, self)

func _exit_tree() -> void:
	
	if nav_agent.is_inside_tree():
		nav_agent.queue_free()

func _ready() -> void:
	SimusNetRPC.register(
		[
			goto,
			goto_target,
			stop,
		], 
		SimusNetRPCConfig.new().flag_mode_to_server().flag_serialization()
	)
	
	if not unit.is_node_ready(): await unit.ready
	
	
	nav_agent.avoidance_enabled = true
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	unit.add_child(nav_agent)

func request_stop() -> void:
	SimusNetRPC.invoke_on_server(stop)

func request_goto(pos: Vector3) -> void:
	SimusNetRPC.invoke_on_server(goto, pos)

func request_goto_target(target: Variant) -> void:
	SimusNetRPC.invoke_on_server(goto_target, target)

func goto(pos: Vector3) -> void:
	current_target_node = null
	move_target_reached = false
	nav_agent.target_position = pos
	unit.state_machine.switch_by_name("moving")

func goto_target(target: Variant) -> void:
	if target is Node3D:
		current_target_node = target
		goto(target.global_position)
	elif target is Vector3:
		goto(target)

func stop() -> void:
	current_target_node = null
	move_target_reached = true
	unit.velocity = Vector3.ZERO
	unit.state_machine.switch_by_name("idle")

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server() or move_target_reached:
		return

	if is_instance_valid(current_target_node):
		nav_agent.target_position = current_target_node.global_position

	if nav_agent.is_navigation_finished():
		stop()
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var direction = (next_path_pos - unit.global_position).normalized()
	var move_dir = Vector3(direction.x, 0, direction.z).normalized()
	
	if move_dir.length() > 0.01:
		var target_basis = Basis.looking_at(move_dir, Vector3.UP)
		unit.global_transform.basis = unit.global_transform.basis.slerp(
			target_basis, 
			unit.resource.get_rotation_speed() * delta
		).orthonormalized()
	
	var forward = -unit.global_transform.basis.z
	if forward.dot(move_dir) > 0.7: 
		unit.velocity = direction * unit.resource.get_movespeed()
		unit.move_and_slide()
