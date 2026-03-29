class_name R_Effect extends Resource

@export var id: StringName = "base_effect"
@export var icon: Texture
@export var effect_script: Script

@export var stackable:bool = false
@export var duration:Array[float] = [1.0]
@export var dispellable:bool = true

@export var data:Dictionary = {}

var level:int = 0


func get_duration() -> float:
	return AE.get_leveled_value(level, duration)

func create(caster:Variant, spell:Spell, target:Variant) -> Effect:
	var new_effect = effect_script.new()
	
	if new_effect is Effect:
		new_effect.caster = caster
		new_effect.spell = spell
		new_effect.target = target
		new_effect.res = self.duplicate()
		new_effect.res.level = spell.res.level
		
		return new_effect
	
	return null
