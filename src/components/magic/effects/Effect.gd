class_name Effect extends RefCounted

signal finished

var is_finished: bool = false

var caster: Variant
var spell: Spell
var target: Unit
var res: R_Effect

var time_left: float = 0.0 :
	set(val):
		time_left = val
		if time_left <= 0.0:
			finish()


func on_start() -> void:
	pass

func on_finish() -> void:
	pass

func on_dispell() -> void:
	pass

func on_update(delta: float) -> void:
	pass

func update(delta: float) -> void:
	if is_finished:
		return
	time_left -= delta
	on_update(delta)

func dispell() -> void:
	on_dispell()
	finish()


func apply() -> void:
	target.unit_effects.add_effect(self)

func finish() -> void:
	if is_finished: return
	is_finished = true
	on_finish()
	finished.emit()
