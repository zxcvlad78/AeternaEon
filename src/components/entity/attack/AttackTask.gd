class_name AttackTask extends UnitTask

func start() -> void:
	unit.ct_attack.attack(target)

func cancel() -> void:
	unit.animated_model.stop_tree_oneshot()
	unit.ct_attack.current_target = null
	unit.ct_attack.should_attack = false
