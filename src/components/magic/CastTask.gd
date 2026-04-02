class_name CastTask extends UnitTask

var spell:Spell

func _init(_unit:Unit = null, _target:Variant = null, _spell:Spell = null):
	SimusNetVars.register(
		self,
		[
			"spell"
		],
		#SimusNetVarConfig.new()
	)
	
	super(_unit, _target)
	spell = _spell

func simusnet_serialize(serializer:SimusNetCustomSerialization) -> void:
	var id:SimusNetIdentity = SimusNetIdentity.register(self)
	serializer.pack(id.get_unique_id())
	
	serializer.pack(unit)
	serializer.pack(target)
	serializer.pack(spell)

static func simusnet_deserialize(serializer:SimusNetCustomSerialization) -> void:
	var task:CastTask = CastTask.new()
	SimusNetIdentity.register(task, serializer.unpack())
	
	task.unit = serializer.unpack()
	task.target = serializer.unpack()
	task.spell = serializer.unpack()
	
	serializer.set_result(task)

func start() -> void:
	if is_instance_valid(spell):
		spell.precast(target)
		spell.casted.connect(on_finish, CONNECT_ONE_SHOT)

func cancel() -> void:
	if is_instance_valid(spell):
		spell.should_cast = false
		spell.spell_machine.interrupt_cast()
