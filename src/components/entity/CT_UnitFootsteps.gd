@tool
class_name CT_UnitFootsteps extends Node3D

@export var unit:Unit :
	set(val):
		unit = val
		_auto_bind_footstep()

func _auto_bind_footstep() -> void:
	if not unit:
		return
	
	var model = unit.animated_model
	if model:
		model.footstep.connect(do_footstep)

func _enter_tree() -> void:
	_auto_set_unit()
	_auto_bind_footstep()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_auto_set_unit()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	SimusNetRPC.register(
		[
			_local_do_footstep
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func _auto_set_unit() -> void:
	if not unit:
		var parent = get_parent()
		if parent is Unit:
			unit = parent

func _local_do_footstep() -> void:
	var footsteps:Array[AudioStream] = unit.resource.footsteps
	if footsteps.is_empty():
		return
	
	var footstep:AudioStream = footsteps.pick_random()
	
	s_Audio.play_global(footstep, self.global_position)

func do_footstep() -> void:
	SimusNetRPC.invoke_all(_local_do_footstep)
