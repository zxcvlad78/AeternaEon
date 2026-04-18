@tool
class_name AnimatedModel extends W_AnimatedModel3D

signal footstep
signal hit

@export var target:Unit
@export var state_machine_name:String = "StateMachine"
@export var state_machine_properties:Dictionary[String, String]
@export var state_exceptions:Array[String]

var state_machine:SD_NodeStateMachine

var initialized:bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if target and is_instance_valid(target):
		await target.ready
		initialize()
	
	SimusNetRPC.register(
		[
			_local_play_tree_oneshot_by_name,
			_local_stop_tree_oneshot
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func initialize() -> void:
	initialized = is_instance_valid(target)
	if not initialized:
		return
	state_machine = target.state_machine
	
	if is_instance_valid(state_machine):
		state_machine.state_enter.connect(switch_state)

func emit_footstep() -> void:
	footstep.emit()
func emit_hit() -> void:
	hit.emit()

func set_blend_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	for i in state_machine_properties:
		var _property_path = "parameters/%s/%s/blend_position" % [state_machine_name, i]
		tree.set(_property_path, target.get(state_machine_properties[i]))

func set_oneshot_parameter(oneshot_name:StringName, param:StringName,  value:Variant) -> void:
	var tree_root = tree.tree_root
	if tree_root is AnimationNodeBlendTree:
		var oneshot = tree_root.get_node(oneshot_name)
		if oneshot is AnimationNodeOneShot:
			oneshot.set(param, value)

func play_tree_oneshot_by_name(anim_name:StringName, speed_scale:float = 1.0) -> void:
	SimusNetRPC.invoke_all(_local_play_tree_oneshot_by_name, anim_name, speed_scale)

func _local_play_tree_oneshot_by_name(anim_name:StringName, speed_scale:float = 1.0, fadein_time:float = 0.05, fadeout_time:float = 0.05) -> void:
	if not anim_name:
		return
	if not library.has_animation(anim_name):
		return
	
	var tree_root = (tree.tree_root as AnimationNodeBlendTree)
	
	set_oneshot_animation_speed(speed_scale)
	
	set_oneshot_parameter("OneShot", "fadein_time", fadein_time)
	set_oneshot_parameter("OneShot", "fadeout_time", fadeout_time)
	
	var lib_name:StringName = library.resource_name
	if lib_name.is_empty():
		lib_name = library.resource_path.get_file().get_basename()
	
	var animation_node:AnimationNodeAnimation = tree_root.get_node("OneshotAnimation")
	animation_node.animation = "%s/%s" % [lib_name, anim_name]
	
	tree.set("parameters/OneShot/request", AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE)

func play_tree_oneshot_by_array(array:Array[StringName], speed_scale:float = 1.0) -> void:
	if array.is_empty():
		return
	
	play_tree_oneshot_by_name(array.pick_random(), speed_scale)

func play_tree_oneshot(resource:Animation, speed_scale:float = 1.0) -> void:
	play_tree_oneshot_by_name(resource.resource_name, speed_scale)

func stop_tree_oneshot() -> void:
	SimusNetRPC.invoke_all(_local_stop_tree_oneshot)

func _local_stop_tree_oneshot() -> void:
	tree.set("parameters/OneShot/request", AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_ABORT)

func is_tree_oneshot_playing() -> bool:
	return tree.get("parameters/OneShot/active")

func set_oneshot_animation_speed(value:float = 1.0) -> void:
	tree.set("parameters/OneshotAnimationSpeedScale/scale", value)

func switch_state(state:SD_State) -> void:
	if state.name in state_exceptions:
		return
	
	
	var state_machine_path = "parameters/%s/playback" % state_machine_name
	var tree_state_machine = tree.get("parameters/%s" % state_machine_name) as AnimationNodeStateMachine
	var state_machine_playback = tree.get(state_machine_path) as AnimationNodeStateMachinePlayback
	state_machine_playback.travel(state.name)

func _process(_delta: float) -> void:
	if not initialized:
		return
	
	set_blend_tree()
