class_name SpellMachine extends Node3D

@export var unit:Unit

@export var spells:Array[R_Spell]

var spell_channeling:SpellChanneling

func interrupt_cast() -> void:
	if spell_channeling:
		spell_channeling.interrupt()
		spell_channeling = null

func _ready() -> void:
	_create_spells()

func _create_spells() -> void:
	for spell in spells:
		spell.create(self)

func try_precast(idx: int) -> Error:
	if spell_channeling and spell_channeling.is_active:
		return FAILED
	
	var child = get_child(idx)
	if not is_instance_valid(child):
		return FAILED
	if child is Spell:
		var target_type = child.res.target_type
		
		if target_type == R_Spell.TargetType.NO_TARGET:
			child.precast()
		elif target_type == R_Spell.TargetType.UNIT_TARGET:
			child.precast()
		elif target_type == R_Spell.TargetType.POINT_TARGET:
			child.precast()
	else:
		return FAILED
	
	return OK

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cast_spell_0"): try_precast(0)
	elif Input.is_action_just_pressed("cast_spell_1"): try_precast(1)
	elif Input.is_action_just_pressed("cast_spell_2"): try_precast(2)
	elif Input.is_action_just_pressed("cast_spell_3"): try_precast(3)
	elif Input.is_action_just_pressed("cast_spell_4"): try_precast(4)
	elif Input.is_action_just_pressed("cast_spell_5"): try_precast(5)
	elif Input.is_action_just_pressed("cast_spell_6"): try_precast(6)
	elif Input.is_action_just_pressed("cast_spell_7"): try_precast(7)
	elif Input.is_action_just_pressed("cast_spell_8"): try_precast(8)
	elif Input.is_action_just_pressed("cast_spell_9"): try_precast(9)
