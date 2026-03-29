extends Effect

func on_start() -> void:
	target.state_machine.switch_by_name("stunned")

func on_finish() -> void:
	target.state_machine.switch_by_name("idle")
