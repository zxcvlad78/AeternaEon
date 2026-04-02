class_name SpellMachine extends Node3D

signal spell_requested(spell:Spell)

@export var unit:Unit

@export var spells:Array[R_Spell]
var spell_instances:Array[Spell]

var spell_channeling:SpellChanneling

var waiting_for_target:bool = false

func interrupt_cast() -> void:
	if spell_channeling:
		spell_channeling.interrupt()
		spell_channeling = null

func _ready() -> void:
	SD_ECS.append_to(unit, self)
	
	SimusNetRPC.register(
		[
			_server_try_precast
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	_create_spells()

func _create_spells() -> void:
	for spell in spells:
		var new_spell = spell.create(self)
		spell_instances.append(new_spell)

func _requeset_try_precast(idx: int) -> void:
	if idx < 0 or idx >= spell_instances.size():
		return
	
	var spell = spell_instances[idx]
	if not is_instance_valid(spell) or not spell.can_cast():
		return

	waiting_for_target = false 
	
	var player = PlayerCamera.i()
	player.unit_selected.emit(null)
	player.point_selected.emit(null)
	var target_type = spell.res.target_type
	var shift = Input.is_action_pressed("shift")

	if target_type == R_Spell.TargetType.NO_TARGET:
		SimusNetRPC.invoke_on_server(_server_try_precast, spell, shift)
	else:
		waiting_for_target = true
		unit.mesh_cast_range.show_range(spell)
		player.target_select_mode = target_type
		
		spell_requested.emit(spell)
		
		var target
		if target_type == R_Spell.TargetType.UNIT_TARGET:
			target = await player.unit_selected
		elif target_type == R_Spell.TargetType.POINT_TARGET:
			target = await player.point_selected
		
		
		if not is_instance_valid(self):
			return
		
		waiting_for_target = false
		unit.mesh_cast_range.hide()
		player.target_select_mode = R_Spell.TargetType.NO_TARGET
		
		if target:
			SimusNetRPC.invoke_on_server(_server_try_precast, spell, shift, target)

func _server_try_precast(p_spell:Spell, shift:bool, target:Variant = null) -> Error:
	if spell_channeling:
		return FAILED
	
	var task = CastTask.new(unit, target, p_spell)
	task.icon = p_spell.res.icon
	unit.unit_orders.issue_task(task, shift)
	
	return OK

func _input(_event: InputEvent) -> void:
	var player = PlayerCamera.i()
	if not is_instance_valid(player):
		return
	if not player.get_main_unit() == unit:
		return
	
	if Input.is_action_just_pressed("cast_spell_0"): _requeset_try_precast(0)
	elif Input.is_action_just_pressed("cast_spell_1"): _requeset_try_precast(1)
	elif Input.is_action_just_pressed("cast_spell_2"): _requeset_try_precast(2)
	elif Input.is_action_just_pressed("cast_spell_3"): _requeset_try_precast(3)
	elif Input.is_action_just_pressed("cast_spell_4"): _requeset_try_precast(4)
	elif Input.is_action_just_pressed("cast_spell_5"): _requeset_try_precast(5)
	elif Input.is_action_just_pressed("cast_spell_6"): _requeset_try_precast(6)
	elif Input.is_action_just_pressed("cast_spell_7"): _requeset_try_precast(7)
	elif Input.is_action_just_pressed("cast_spell_8"): _requeset_try_precast(8)
	elif Input.is_action_just_pressed("cast_spell_9"): _requeset_try_precast(9)
