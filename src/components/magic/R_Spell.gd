class_name R_Spell extends Resource

@export var name:StringName = "Spell"
@export var icon:Texture
@export_multiline() var description: String = ""

enum AbilityType {
	ACTIVE,
	PASSIVE,
}

enum TargetType {
	NO_TARGET,
	UNIT_TARGET,
	POINT_TARGET,
}

@export var spell_data: Dictionary[String, Array] = {} 

@export var effects:Array[R_Effect]

@export_group("Particles")
@export var particles:R_ParticlesSettings = R_ParticlesSettings.new()

@export_group("Audio")
@export var precast_sound:R_Audio
@export var cast_sound:R_Audio

@export_group("Behaviour")
@export var spell_script:Script

@export var ability_type:AbilityType = AbilityType.ACTIVE
@export var target_type:TargetType = TargetType.NO_TARGET

@export var base_cast_point:Array[float] = [0.0]
func get_cast_point() -> float:
	return AE.get_leveled_value(level, base_cast_point)

@export var base_cast_range:Array[float] = []
func get_cast_range() -> float:
	return AE.get_leveled_value(level, base_cast_range)

@export var base_radius:Array[float] = []
func get_radius() -> float:
	return AE.get_leveled_value(level, base_radius)

@export var base_cooldown: Array[float] = [0]
func get_cooldown() -> float:
	return AE.get_leveled_value(level, base_cooldown)

@export var base_mana_cost: Array[float] = [0]
func get_mana_cost() -> float:
	return AE.get_leveled_value(level, base_mana_cost)

@export_category("Animation")
@export var swing_animations:Array[R_SpellAnimation]
@export var backswing_animations:Array[R_SpellAnimation]

@export_group("Level")
var level:int = 0
@export var max_level:int = 4
@export var required_level:int = 1

#region Serialization
func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	var is_copy:bool = resource_path.is_empty()
	serialization.pack(is_copy)
	if !is_copy:
		serialization.pack(resource_path)
		return
	
	serialization.pack(name)
	serialization.pack(icon)
	serialization.pack(description)
	serialization.pack(spell_data)
	serialization.pack(effects)
	serialization.pack(particles)
	serialization.pack(precast_sound)
	serialization.pack(cast_sound)
	serialization.pack(spell_script)
	serialization.pack(target_type)
	serialization.pack(base_cast_point)
	serialization.pack(base_cast_range)
	serialization.pack(base_radius)
	serialization.pack(base_cooldown)
	serialization.pack(base_mana_cost)
	serialization.pack(swing_animations)
	serialization.pack(backswing_animations)
	serialization.pack(level)
	serialization.pack(max_level)
	serialization.pack(required_level)

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var r_spell = R_Spell.new()
	var is_copy:bool = serialization.unpack()
	
	if !is_copy:
		var res_path = serialization.unpack()
		r_spell = load(res_path)
	else:
		r_spell.name = serialization.unpack()
		r_spell.icon = serialization.unpack()
		r_spell.description = serialization.unpack()
		r_spell.spell_data = serialization.unpack()
		r_spell.effects = serialization.unpack()
		r_spell.particles = serialization.unpack()
		r_spell.precast_sound = serialization.unpack()
		r_spell.cast_sound = serialization.unpack()
		r_spell.spell_script = serialization.unpack()
		r_spell.target_type = serialization.unpack()
		r_spell.base_cast_point = serialization.unpack()
		r_spell.base_cast_range = serialization.unpack()
		r_spell.base_radius = serialization.unpack()
		r_spell.base_cooldown = serialization.unpack()
		r_spell.base_mana_cost = serialization.unpack()
		r_spell.swing_animations = serialization.unpack()
		r_spell.backswing_animations = serialization.unpack()
		r_spell.level = serialization.unpack()
		r_spell.max_level = serialization.unpack()
		r_spell.required_level = serialization.unpack()
	
	serialization.set_result(r_spell)
#endregion


func create(spell_machine:SpellMachine) -> Spell:
	if not spell_machine:
		return
	if not spell_script:
		return
	
	var new_spell = spell_script.new()
	if new_spell is Node3D:
		new_spell.name = self.name
	
	new_spell.spell_machine = spell_machine
	new_spell.res = self.duplicate()
	
	spell_machine.add_child(new_spell)
	
	
	return new_spell
