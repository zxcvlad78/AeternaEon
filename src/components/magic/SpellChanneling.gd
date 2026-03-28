class_name SpellChanneling extends RefCounted

signal finished(is_success: bool)

var spell_machine: SpellMachine
var spell:Spell
var is_active: bool = false

func _init(p_spell_machine:SpellMachine = null, p_spell:Spell = null) -> void:
	spell_machine = p_spell_machine
	spell = p_spell

func start(time: float) -> void:
	spell_machine.unit.ct_movement.stop()
	is_active = true
	var timer = spell_machine.get_tree().create_timer(time)
	
	await timer.timeout
	
	if is_active:
		_finish(true)

func interrupt() -> void:
	if is_active:
		_finish(false)

func _finish(is_success: bool) -> void:
	is_active = false
	spell_machine.unit.animated_model.stop_tree_oneshot()
	finished.emit(is_success)
