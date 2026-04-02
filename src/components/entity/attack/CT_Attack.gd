class_name CT_Attack extends Node

@export var unit:Unit

var current_target:Variant
var should_attack:bool = false

var is_attacking: bool = false

var swing_timer:Timer
var cooldown_timer:Timer

var animation:R_Animation

func _ready() -> void:
	if not unit:
		return
	
	SD_ECS.append_to(unit, self)
	
	SimusNetRPC.register(
		[
			_server_order_task,
			_local_swing,
			_local_impact,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	if multiplayer.is_server():
		swing_timer = Timer.new()
		swing_timer.one_shot = true
		add_child(swing_timer)
		swing_timer.timeout.connect(_on_swing_finished)
		
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

func stop_attack() -> void:
	is_attacking = false
	should_attack = false
	if swing_timer:
		swing_timer.stop()
	unit.animated_model.stop_tree_oneshot() 

func swing(target: Variant) -> void:
	if is_attacking or in_cooldown():
		return
	
	is_attacking = true
	unit.ct_movement.stop()

	if unit.resource.attack_animations:
		animation = unit.resource.attack_animations.pick_random()
	else:
		animation = R_Animation.new()

	SimusNetRPC.invoke_all(_local_swing, target, animation)
	
	var swing_duration = unit.resource.get_attack_speed()
	swing_timer.start(swing_duration)
	print(swing_timer.wait_time)

func _on_swing_finished() -> void:
	is_attacking = false
	if not is_instance_valid(current_target) or not can_reach(current_target):
		return
	
	impact(current_target)

func _local_swing(target: Variant, _animation: R_Animation) -> void:
	animation = _animation
	_play_animation(animation.swing)
	_play_audio(unit.resource.swing_audio)

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

func order_task(target:Variant, shift:bool = false) -> void:
	SimusNetRPC.invoke_on_server(_server_order_task, target, shift)

func _server_order_task(target:Variant, shift:bool = false) -> void:
	if target == unit:
		return
	var attack_task = AttackTask.new(unit, target)
	unit.unit_orders.issue_task(attack_task, shift)

func _process(delta: float) -> void:
	if not multiplayer.is_server() or not should_attack:
		return
	
	if not is_instance_valid(current_target):
		should_attack = false
		return

	if can_reach(current_target):
		if not in_cooldown() and not is_attacking:
			swing(current_target)
	else:
		if not is_attacking:
			unit.ct_movement.goto_target(current_target)
