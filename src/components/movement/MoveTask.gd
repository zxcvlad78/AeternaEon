class_name MoveTask extends UnitTask

func start() -> void:
	unit.ct_movement.nav_agent.target_reached.connect(on_finish, CONNECT_ONE_SHOT)
	unit.ct_movement.request_goto_target(target)

func cancel() -> void:
	unit.ct_movement.request_stop()
	on_finish()
