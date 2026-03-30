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
		
		if SimusNetConnection.is_server():
			if time_left <= 0.0:
				SimusNetRPC.invoke_all(finish)

func simusnet_serialize(serializer:SimusNetCustomSerialization) -> void:
	serializer.pack(get_script())
	var id:SimusNetIdentity = SimusNetIdentity.register(self)
	serializer.pack(id.get_unique_id())
	
	serializer.pack(caster)
	serializer.pack(spell)
	serializer.pack(target)
	serializer.pack(res)
	

static func simusnet_deserialize(serializer:SimusNetCustomSerialization) -> void:
	var script:Script = serializer.unpack()
	
	var effect:Effect = script.new()
	SimusNetIdentity.register(effect, serializer.unpack())
	
	effect.caster = serializer.unpack()
	effect.spell = serializer.unpack()
	effect.target = serializer.unpack()
	effect.res = serializer.unpack()
	
	serializer.set_result(effect)

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

func start() -> void:
	SimusNetIdentity.register(self)
	
	SimusNetVars.register(
		self,
		["time_left"],
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication().flag_tickrate(16.0)
	)
	
	SimusNetRPC.register(
		[
			finish
		],
		SimusNetRPCConfig.new().flag_mode_server_only()
	)
	
	on_start()

func apply() -> void:
	target.unit_effects.add_effect(self)

func finish() -> void:
	if is_finished: return
	is_finished = true
	on_finish()
	finished.emit()
