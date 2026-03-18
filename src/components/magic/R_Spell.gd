
class_name R_Spell extends Resource

@export var name:StringName = "Spell"
@export var icon:Texture
@export_multiline() var description: String = ""

enum TargetType {
	NO_TARGET,
	UNIT_TARGET,
	POINT_TARGET,
}

@export_group("Particles")
@export var particles:R_ParticlesSettings = R_ParticlesSettings.new()

@export_group("Audio")
@export var precast_sound:AudioStream
@export var cast_sound:AudioStream

@export_group("Behaviour")
@export var spell_script:Script

@export var target_type:TargetType = TargetType.NO_TARGET
@export var base_precast_time:float = 0.0

@export var base_cast_range:Array[float] = []
@export var base_radius:Array[float] = []

@export var base_cooldown: Array[float] = [0]
@export var base_mana_cost: Array[float] = [0]

@export_category("Animation")
@export var swing_animation_names:Array[StringName]
@export var backswing_animation_names:Array[StringName]

@export_group("Level")
var level:int = 0
@export var max_level:int = 4
@export var required_level:int = 1

func create(spell_machine:SpellMachine) -> Spell:
	if not spell_machine:
		return
	if not spell_script:
		return
	
	var new_spell = spell_script.new()
	if new_spell is Spell:
		print("Privet")
	
	new_spell.spell_machine = spell_machine
	new_spell.res = self.duplicate()
	
	spell_machine.add_child(new_spell)
	
	return new_spell
