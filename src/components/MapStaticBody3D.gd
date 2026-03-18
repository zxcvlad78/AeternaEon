class_name MapStaticBody3D extends StaticBody3D

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				
				var player = PlayerCamera.i()
				if not is_instance_valid(player):
					return
				
				var unit = player.get_main_unit()
				if not unit:
					return
				
				var ct_movement = player.get_main_unit().ct_movement
				
				if not is_instance_valid(ct_movement):
					return
				
				ct_movement.request_goto(event_position)
