class_name FootstepComponent extends Node

@onready var unit:BaseUnit = get_parent()

func _ready() -> void:
	randomize()
	unit.model_root.footstep.connect(do_footstep)


func do_footstep() -> void:
	GlobalAudioPlayer.create_3d(
		unit,
		unit.unit_resource.footsteps_sounds.pick_random()
		).play()
