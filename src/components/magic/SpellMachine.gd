class_name SpellMachine extends Node3D

@export var unit:Unit

@export var spells:Array[R_Spell]
var spell_instances:Array[Spell]

var spell_channeling:SpellChanneling

func interrupt_cast() -> void:
	if spell_channeling:
		spell_channeling.interrupt()
		spell_channeling = null

func _ready() -> void:
	SimusNetVars.register(
		self,
		[
			"unit",
			"spells",
		]
		,SimusNetVarConfig.new().flag_mode_server_only().flag_replication().flag_serialization()
	)
	
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

func _requset_try_precast(idx: int) -> void:
	var spell = spell_instances[idx]
	if not is_instance_valid(spell) or not spell.can_cast():
		print(1)
		return
	
	var player = PlayerCamera.i()
	var target_type = spell.res.target_type
	
	if target_type == R_Spell.TargetType.NO_TARGET:
		SimusNetRPC.invoke_on_server(_server_try_precast, spell)
	else:
		player.target_select_mode = target_type
		
		var target = null
		if target_type == R_Spell.TargetType.UNIT_TARGET:
			target = await player.unit_selected
		elif target_type == R_Spell.TargetType.POINT_TARGET:
			target = await player.point_selected
			
		if target != null:
			SimusNetRPC.invoke_on_server(_server_try_precast, spell, target)
	
	#player.target_select_mode = R_Spell.TargetType.NO_TARGET
	
	#SimusNetRPC.invoke_on_server(_server_try_precast)

func _server_try_precast(p_spell:Spell, target:Variant = null) -> Error:
	if spell_channeling and spell_channeling.is_active:
		return FAILED
	
	p_spell.precast(target)
	PlayerCamera.find_by_peer(SimusNetRemote.sender_id).target_select_mode = R_Spell.TargetType.NO_TARGET
	return OK

func _input(_event: InputEvent) -> void:
	var player = PlayerCamera.i()
	if not is_instance_valid(player):
		return
	if not player.get_main_unit() == unit:
		return
	
	if Input.is_action_just_pressed("cast_spell_0"): _requset_try_precast(0)
	elif Input.is_action_just_pressed("cast_spell_1"): _requset_try_precast(1)
	elif Input.is_action_just_pressed("cast_spell_2"): _requset_try_precast(2)
	elif Input.is_action_just_pressed("cast_spell_3"): _requset_try_precast(3)
	elif Input.is_action_just_pressed("cast_spell_4"): _requset_try_precast(4)
	elif Input.is_action_just_pressed("cast_spell_5"): _requset_try_precast(5)
	elif Input.is_action_just_pressed("cast_spell_6"): _requset_try_precast(6)
	elif Input.is_action_just_pressed("cast_spell_7"): _requset_try_precast(7)
	elif Input.is_action_just_pressed("cast_spell_8"): _requset_try_precast(8)
	elif Input.is_action_just_pressed("cast_spell_9"): _requset_try_precast(9)
