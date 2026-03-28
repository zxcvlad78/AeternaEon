class_name CastTask extends UnitTask

var spell:Spell

func _init(_unit:Unit, _target:Variant, _spell:Spell):
	super(_unit, _target)
	spell = _spell

func start() -> void:
	spell.precast(target)
	spell.casted.connect(on_finish, CONNECT_ONE_SHOT)

func cancel() -> void:
	spell.should_cast = false
	spell.spell_machine.interrupt_cast()
