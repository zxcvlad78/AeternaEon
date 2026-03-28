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
			_local_precast,
			_cast
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	SimusNetVars.register(
		self,
		[
			"last_target"
		],
		SimusNetVarConfig.new().flag_serialization().flag_replication()
	)

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
	
	return get_unit().global_position.distance_to(target.global_position) < res.get_leveled_value(res.base_cast_range)

func _play_animation(anim_names:Array[StringName]) -> void:
	if anim_names.is_empty():
		return
	var model = spell_machine.unit.animated_model
	
	if model:
		model.play_tree_oneshot_by_name(anim_names.pick_random())

func _spawn_partilces(particles:R_Particles) -> void:
	s_Particles.spawn(self, particles, spell_machine.global_position)

func _play_audio(audio:R_SpellAudio) -> void:
	var player = AudioStreamPlayer3D.new()
	player.pitch_scale = randf_range(audio.pitch.x, audio.pitch.y)
	s_Audio.play_global(audio.stream, spell_machine.global_position, player)

func _local_precast(target:Variant = null) -> void:
	_play_animation(res.swing_animation_names)
	_spawn_partilces(res.particles.precast)
	_play_audio(res.precast_sound)
	
	if multiplayer.is_server():
		var cast_point = res.get_leveled_value(res.base_cast_point)
		if cast_point == 0.0:
			SimusNetRPC.invoke_all(_cast, target)
			return
		
		var channel = SpellChanneling.new(spell_machine, self)
		spell_machine.spell_channeling = channel
		
		channel.start(cast_point)
		
		var success = await channel.finished
		if success:
			SimusNetRPC.invoke_all(_cast, target)
		
		if spell_machine.spell_channeling == channel:
			spell_machine.spell_channeling = null

func precast(target:Variant = null) -> void:
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
	_play_animation(res.backswing_animation_names)
	_spawn_partilces(res.particles.cast)
	_play_audio(res.cast_sound)
	
	on_cast(target)
	casted.emit()
	
	if multiplayer.is_server():
		pass

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
