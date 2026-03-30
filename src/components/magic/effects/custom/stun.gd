extends Effect

func on_start() -> void:
	if SimusNetConnection.is_server():
		target.state_machine.switch_by_name("stunned")

func on_finish() -> void:
	if SimusNetConnection.is_server():
		target.state_machine.switch_by_name("idle")
