class_name SpellContainer extends Node3D

signal on_spell_chosed

var spells:Array[Spell]
var unit:BaseUnit

var casting:bool = false : set = set_casting, get = is_casting
var chosed_spell:Spell = null :
	set(val):
		chosed_spell = val
		on_spell_chosed.emit()

var current_cast:Spell = null
var casted_spell:Spell = null

func _ready() -> void:
	child_entered_tree.connect(_update)
	_update()
	
	unit = get_parent()
	await unit.ready

func is_casting() -> bool:
	return casting
func set_casting(value:bool) -> void:
	casting = value

func get_spell_by_node_name(spell_name:String) -> Spell:
	var spell = get_node(spell_name)
	if is_instance_valid(spell) and spell is Spell:
		return spell
	
	return null

func get_spell(res:R_Spell) -> Spell:
	for child in get_children():
		if child is Spell:
			if child.resource == res:
				return child
	
	return null

func get_spells(res:R_Spell) -> Array[R_Spell]:
	var result:Array[R_Spell]
	for child in get_children():
		if child is Spell:
			if child.resource == res:
				result.append(child)
	
	return result

func get_spell_by_res_name(spell_name:String) -> Spell:
	for child in get_children():
		if child is Spell:
			if child.resource._name == spell_name:
				return child 
	
	return null

func _update(n:Node=null) -> void:
	spells = []
	for child in get_children():
		if child is Spell:
			if spells.has(child):
				continue
			spells.append(child)
	
	if is_instance_valid(PlayerUI.instance):
		PlayerUI.instance.spell_list_box_container._update()

func enter_unit_target_mode() -> void:
	Player.get_by_peer_id(unit.controllable.owner_id).pick_spell_target_mode = true
func exit_unit_target_mode() -> void:
	chosed_spell = null
	Player.get_by_peer_id(unit.controllable.owner_id).pick_spell_target_mode = false

func pick_target(target) -> void:
	if not is_instance_valid(chosed_spell):
		return
	
	
	chosed_spell.precast(target)
	exit_unit_target_mode()

func try_cast_spell_by_idx(idx:int) -> void:
	if is_casting():
		return
	if idx > spells.size() - 1:
		return
	
	var spell = spells[idx]
	
	if not is_instance_valid(spell):
		return
	
	if spell.resource.target_type == R_Spell.Target.NO_TARGET:
		spell.precast()
	elif spell.resource.target_type == R_Spell.Target.UNIT_TARGET:
		enter_unit_target_mode()
		chosed_spell = spell

func _input(event: InputEvent) -> void:
	if (not is_multiplayer_authority()) \
		or (not Player.get_local_instance().current_unit == unit) \
		or (SimusDev.ui.has_active_interface()):
		
		return
	
	if event.is_pressed():
		if Input.is_action_just_pressed("ui_cancel"):
			exit_unit_target_mode()
		if Input.is_action_just_pressed("spell1"): try_cast_spell_by_idx(0)
		if Input.is_action_just_pressed("spell2"): try_cast_spell_by_idx(1)
		if Input.is_action_just_pressed("spell3"): try_cast_spell_by_idx(2)
		if Input.is_action_just_pressed("spell4"): try_cast_spell_by_idx(3)
		if Input.is_action_just_pressed("spell5"): try_cast_spell_by_idx(4)
		if Input.is_action_just_pressed("spell6"): try_cast_spell_by_idx(5)
