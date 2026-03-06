class_name MapStaticBody extends StaticBody3D

var player:Player

func _ready() -> void:
	player = Player.get_local_instance()
	input_event.connect(on_input_event)

func on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if SD_Network.is_authority(self):
		if is_instance_valid(Player.get_local_instance()):
			if is_instance_valid(Player.get_local_instance().current_unit):
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_RIGHT:
						if event.pressed:
							if Player.get_local_instance().current_unit.controllable.can_controll:
								Player.get_local_instance().current_unit.attack_component.current_target = null
								Player.get_local_instance().current_unit.controllable.goto(event_position)
