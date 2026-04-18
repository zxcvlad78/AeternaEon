class_name Spell extends Node3D

signal casted

var spell_machine:SpellMachine = null
var res:R_Spell

var should_cast:bool = false
var last_target:Variant = null

func _enter_tree() -> void:
	if not spell_machine:
		var parent = get_parent()
		if parent is SpellMachine:
			spell_machine = parent

func _ready() -> void:
	SimusNetRPC.register(
		[
			_server_sync_var,
			_receive_var,
			
			_local_precast,
			_cast,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	SimusNetVars.register(
		self,
		[
			"last_target"
		],
		SimusNetVarConfig.new().flag_replication()
	)

func sync_var(node:Node, var_name:String) -> void:
	SimusNetRPC.invoke_on_server(_server_sync_var, node, var_name)

func _server_sync_var(node:Node, var_name:String) -> void:
	SimusNetRPC.invoke_on_sender(
		_receive_var, node, var_name, node.get(var_name)
	)

func _receive_var(node:Node,  var_name:String, var_val:Variant) -> void:
	if not node:
		return
	node.set(var_name, var_val)


func get_unit() -> Unit:
	return spell_machine.unit

func can_cast(target:Variant = null) -> bool:
	if res.level < res.required_level:
		return false
	
	return true

func can_reach(target:Variant) -> bool:
	if res.target_type == R_Spell.TargetType.NO_TARGET:
		return true
	
	if not target:
		return false
	
	return get_unit().global_position.distance_to(target.global_position) < res.get_cast_range()

func _play_animation(animations:Array[R_SpellAnimation]) -> void:
	if animations.is_empty():
		return
	var model = spell_machine.unit.animated_model
	
	if model:
		var rand_anim = animations.pick_random() as R_SpellAnimation
		model._local_play_tree_oneshot_by_name(
			rand_anim.name,
			1.0,
			rand_anim.fadein_time,
			rand_anim.fadeout_time
			)

func _spawn_partilces(particles:R_Particles) -> void:
	s_Particles.spawn(self, particles, spell_machine.global_position)

func _apply_effects(target:Variant, _effects:Array[R_Effect] = res.effects) -> void:
	if not target:
		return
	
	for effect in _effects:
		var new_effect = effect.create(get_unit(), self, target)
		new_effect.apply()

func _play_audio(audio:R_Audio) -> void:
	if !multiplayer.is_server():
		return
	if not audio:
		return
	
	if audio.stream_list.is_empty():
		return
	
	s_Audio.play_global_from_server(
		audio.stream_list.pick_random(),
		spell_machine.unit.global_position,
		true,
		{"pitch_scale": randf_range(audio.pitch.x, audio.pitch.y)}
		)

func _local_precast(target:Variant = null) -> void:
	_play_animation(res.swing_animations)
	_spawn_partilces(res.particles.precast)
	_play_audio(res.precast_sound)
	
	if multiplayer.is_server():
		var cast_point = res.get_cast_point()
		if cast_point == 0.0:
			SimusNetRPC.invoke_all(_cast, target)
			return
		
		var channel = SpellChanneling.new(spell_machine, self)
		spell_machine.spell_channeling = channel
		
		channel.start(cast_point)
		
		var success = await channel.finished
		if success:
			if get_unit().is_disabled():
				return
			SimusNetRPC.invoke_all(_cast, target)
		
		if spell_machine.spell_channeling == channel:
			spell_machine.spell_channeling = null

func precast(target:Variant = null) -> void:
	if get_unit().is_disabled():
		return
	last_target = target
	
	if not can_cast(target):
		return
	
	if not can_reach(target):
		should_cast = true
		return
	
	should_cast = false
	
	SimusNetRPC.invoke_all(_local_precast, target)

func on_spell_start(target:Variant = null) -> void:
	pass

func _cast(target:Variant = null) -> void:
	if multiplayer.is_server():
		_apply_effects(target)
	
	
	on_cast(target)
	casted.emit()
	
	
	_play_animation(res.backswing_animations)
	_spawn_partilces(res.particles.cast)
	_play_audio(res.cast_sound)


func on_cast(target:Variant = null) -> void:
	pass


func _process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	if should_cast:
		spell_machine.unit.ct_movement.goto_target(last_target)
		
		if can_reach(last_target):
			should_cast = false
			SimusNetRPC.invoke_all(_local_precast, last_target)
