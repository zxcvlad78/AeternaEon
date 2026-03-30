class_name CT_Attack extends Node

@export var unit:Unit

var current_target:Variant
var should_attack:bool = false

var is_attacking: bool = false
var cooldown_timer:Timer

var animation:R_Animation

func _ready() -> void:
	if not unit:
		return
	
	SD_ECS.append_to(unit, self)
	
	SimusNetRPC.register(
		[
			_local_swing,
			_local_impact,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	if multiplayer.is_server():
		cooldown_timer = Timer.new()
		cooldown_timer.one_shot = true
		add_child(cooldown_timer)

func in_cooldown() -> bool:
	return cooldown_timer.time_left > 0.0

func _play_animation(anim_name:StringName) -> void:
	if !multiplayer.is_server():
		return
	
	var model = unit.animated_model
	
	if model:
		var animation:Animation = model.library.get_animation(anim_name)
		if animation:
			var target_duration = unit.resource.get_attack_speed()
			
			if target_duration > 0:
				var speed_scale = animation.length / target_duration
				model.play_tree_oneshot_by_name(anim_name, speed_scale)

func _play_audio(audio:R_Audio) -> void:
	if !multiplayer.is_server():
		return
	
	if audio.stream_list.is_empty():
		return
	
	s_Audio.play_global_from_server(
		audio.stream_list.pick_random(),
		unit.global_position,
		true,
		{"pitch_scale": randf_range(audio.pitch.x, audio.pitch.y)}
		)

func can_attack(target:Variant) -> bool:
	if not is_instance_valid(target):
		return false
	
	if unit.is_disabled():
		return false
	
	if in_cooldown():
		return false
	
	return true

func can_reach(target:Variant) -> bool:
	if unit.global_position.distance_to(target.global_position) > unit.resource.base_attack_range:
		return false
	return true

func attack(target:Variant) -> void:
	current_target = target
	
	if not can_attack(target):
		return
	
	if not can_reach(target):
		should_attack = true
		return
	
	#should_attack = false
	swing(current_target)

func swing(target:Variant) -> void:
	unit.ct_movement.stop()
	
	if is_attacking:
		return
	
	is_attacking = true
	
	if unit.resource.attack_animations:
		animation = unit.resource.attack_animations.pick_random()
	else:
		animation = R_Animation.new()
	SimusNetRPC.invoke_all(_local_swing, target, animation)

func _local_swing(target:Variant, _animation:R_Animation) -> void:
	animation = _animation
	_play_animation(animation.swing)
	_play_audio(unit.resource.swing_audio)
	
	if multiplayer.is_server():
		if in_cooldown():
			return
		await get_tree().create_timer(unit.resource.get_attack_speed()).timeout
		is_attacking = false
		if is_instance_valid(current_target):
			if unit.global_position.distance_to(current_target.global_position) > (unit.resource.base_attack_range * 1.5):
				return
			
			impact(current_target)

func impact(target:Variant) -> void:
	SimusNetRPC.invoke_all(_local_impact, target)

func _local_impact(target:Variant) -> void:
	_play_animation(animation.backswing)
	_play_audio(unit.resource.impact_audio)
	
	if multiplayer.is_server():
		cooldown_timer.wait_time = unit.resource.get_attack_speed()
		cooldown_timer.start()
		
		if target is Unit:
			var dmg = R_PointValue.new(unit.resource.get_attack_damage())
			target.ct_health.apply_diminish(dmg)


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	if should_attack:
		if can_reach(current_target):
			attack(current_target)
		else:
			if not is_attacking:
				unit.ct_movement.goto_target(current_target)
