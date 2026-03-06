class_name SpellKnock extends Spell

@export var stun_time:float = 2.0

func _ready() -> void:
	super()


func cast(target: Variant = null) -> void:
	super()
	
	if target is BaseUnit:
		target.health_component.apply_damage(get_res_value(resource.damage))
