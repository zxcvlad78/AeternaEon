class_name Spell extends Node3D

var spell_machine:SpellMachine = null
var res:R_Spell

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
	
	#SimusNetVars.register(
		#self,
		#[
			#"res"
		#],
		#SimusNetVarConfig.new().flag_mode_server_only().flag_serialization().flag_replication()
	#)

func can_cast(target:Variant = null) -> bool:
	if res.level < res.required_level:
		return false
	return true

func _play_animation(anim_names:Array[StringName]) -> void:
	if anim_names.is_empty():
		return
	var model = spell_machine.unit.animated_model
	
	if model:
		model.play_tree_oneshot_by_name(anim_names.pick_random())

func _spawn_partilces(particles:R_Particles) -> void:
	s_Particles.spawn(self, particles, spell_machine.global_position)

func _local_precast(target:Variant = null) -> void:
	_play_animation(res.swing_animation_names)
	_spawn_partilces(res.particles.precast)
	s_Audio.play_global(res.precast_sound, spell_machine.global_position)
	
	if multiplayer.is_server():
		if res.base_precast_time == 0.0:
			SimusNetRPC.invoke_all(_cast, target)
			return
		
		var channel = SpellChanneling.new(spell_machine, self)
		spell_machine.spell_channeling = channel
		
		channel.start(res.base_precast_time)
		
		var success = await channel.finished
		if success:
			SimusNetRPC.invoke_all(_cast, target)
		
		if spell_machine.spell_channeling == channel:
			spell_machine.spell_channeling = null

func precast(target:Variant = null) -> void:
	SimusNetRPC.invoke_all(_local_precast, target)


func _cast(target:Variant = null) -> void:
	_play_animation(res.backswing_animation_names)
	_spawn_partilces(res.particles.cast)
	s_Audio.play_global(res.cast_sound, spell_machine.global_position)
	
	if multiplayer.is_server():
		pass
