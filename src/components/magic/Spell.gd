class_name Spell extends Node3D

var spell_machine:SpellMachine = null
var res:R_Spell

func _enter_tree() -> void:
	if not spell_machine:
		var parent = get_parent()
		if parent is SpellMachine:
			spell_machine = parent

func _play_animation(anim_names:Array[StringName]) -> void:
	if anim_names.is_empty():
		return
	var model = spell_machine.unit.animated_model
	
	if model:
		model.play_tree_oneshot_by_name(anim_names.pick_random())



func precast(target: Variant = null) -> void:
	_play_animation(res.swing_animation_names)
	s_Audio.play_global(res.precast_sound, spell_machine.global_position)
	
	var channel = SpellChanneling.new(spell_machine)
	spell_machine.spell_channeling = channel
	
	channel.start(res.base_precast_time)
	
	var success = await channel.finished
	if success:
		cast(target)
	
	if spell_machine.spell_channeling == channel:
		spell_machine.spell_channeling = null

func cast(target:Variant = null) -> void:
	_play_animation(res.backswing_animation_names)
	s_Audio.play_global(res.cast_sound, spell_machine.global_position)
