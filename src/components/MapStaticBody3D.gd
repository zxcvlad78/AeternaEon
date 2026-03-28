class_name MapStaticBody3D extends StaticBody3D

@export var click_visual:PackedScene
@export var goto_visual:Node3D

func _ready() -> void:
	SimusNetRPC.register(
		[
			_order_move_task
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var player = PlayerCamera.i()
		if not is_instance_valid(player):
			return
		var unit = player.get_main_unit()
		if not unit:
			return
		
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				player.select_point(event_position)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				
				SimusNetRPC.invoke_on_server(
					_order_move_task,
					event_position,
					unit,
					Input.is_action_pressed("shift")
					)
				
				show_goto_visual(event_position)
				#create_click_visual(event_position)

func _order_move_task(pos:Vector3, unit:Unit, shift:bool) -> void:
	var task = MoveTask.new(unit, pos)
	
	unit.unit_orders.issue_task(task, shift)

func show_goto_visual(pos:Vector3) -> void:
	if not goto_visual:
		return
	goto_visual.global_position = pos
	var anim_player:AnimationPlayer = (goto_visual.get_node("AnimationPlayer") as AnimationPlayer)
	if anim_player.is_playing():
		anim_player.seek(0.0)
	anim_player.play("new_animation")

func create_click_visual(pos:Vector3) -> void:
	if not click_visual:
		return
	var inst = click_visual.instantiate()
	get_tree().root.add_child(inst)
	inst.global_position = pos
	
	await get_tree().create_timer(1.0).timeout
	
	inst.queue_free()
