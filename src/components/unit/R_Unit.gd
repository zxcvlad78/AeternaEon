class_name R_Unit extends Resource

signal base_health_changed
signal base_mana_changed

signal base_attack_speed_changed
signal base_attack_range_changed
signal base_attack_interval_changed
signal base_attack_damage_changed

signal base_magic_resistance_changed

signal base_strength_changed
signal base_agility_changed
signal base_intelligence_changed

signal base_movespeed_changed
signal base_rotation_speed_changed

enum Attribute {
	STRENGTH = 0,
	AGILITY,
	INTELLIGENCE
}

@export var name:String = "Unit"
@export var prefab:PackedScene

@export var data:Dictionary

@export_category("Variables")
@export var base_health:float = 100.0 :
	set(val):
		base_health = val
		base_health_changed.emit()

@export var base_mana:float = 200.0 :
	set(val):
		base_mana = val
		base_mana_changed.emit()

@export var main_attribute:Attribute = Attribute.STRENGTH

@export var base_attack_speed:float = 120.0 :
	set(val):
		base_attack_speed = val
		base_attack_speed_changed.emit()

@export var base_attack_range:float = 1.5 :
	set(val):
		base_attack_range = val
		base_attack_range_changed.emit()

@export var base_attack_interval:float = 1.2 :
	set(val):
		base_attack_interval = val
		base_attack_interval_changed.emit()

@export var base_attack_damage:float = 50.0 :
	set(val):
		base_attack_damage = val
		base_attack_damage_changed.emit()

@export var base_magic_resistance:float = 25.0 :
	set(val):
		base_magic_resistance = val
		base_magic_resistance_changed.emit()

@export var base_strength:float = 5.0 :
	set(val):
		base_strength = val
		base_strength_changed.emit()
@export var base_agility:float = 5.0 :
	set(val):
		base_agility = val
		base_agility_changed.emit()
@export var base_intelligence:float = 5.0 :
	set(val):
		base_intelligence = val
		base_intelligence_changed.emit()

@export var base_movespeed:float = 3.0 :
	set(val):
		base_movespeed = val
		base_movespeed_changed.emit()

@export var base_rotation_speed:float = 22.0 :
	set(val):
		base_rotation_speed = val
		base_rotation_speed_changed.emit()

@export_category("Audio")
@export var swing_audio:R_Audio
@export var impact_audio:R_Audio
@export var footsteps:Array[AudioStream] = [
	preload("res://src/audio/footsteps_general/footstep_hero_general1.mp3"),
	preload("res://src/audio/footsteps_general/footstep_hero_general2.mp3"),
	preload("res://src/audio/footsteps_general/footstep_hero_general3.mp3"),
	preload("res://src/audio/footsteps_general/footstep_hero_general4.mp3"),
	preload("res://src/audio/footsteps_general/footstep_hero_general5.mp3"),
	preload("res://src/audio/footsteps_general/footstep_hero_general6.mp3"),
	preload("res://src/audio/footsteps_general/footstep_hero_general7.mp3"),
]

@export_group("Animation")
@export var attack_animations:Array[R_Animation]

@export_group("Portrait")
@export var portrait:R_UnitPortrait = R_UnitPortrait.new()

func get_health_regen() -> float:
	return base_strength * 0.09
func get_max_health() -> float:
	return base_health + base_strength * 22

func get_mana_regen() -> float:
	return base_intelligence * 0.05
func get_max_mana() -> float:
	return base_mana + base_intelligence * 12

func get_attack_speed() -> float:
	var total_as = base_attack_speed + base_agility
	return base_attack_interval / (total_as / 100.0)

func get_attack_damage() -> float:
	if main_attribute == Attribute.STRENGTH:
		return base_attack_damage + base_strength
	elif main_attribute == Attribute.AGILITY:
		return base_attack_damage + base_agility
	elif main_attribute == Attribute.INTELLIGENCE:
		return base_attack_damage + base_intelligence
	return 0.0

func get_rotation_speed() -> float:
	return base_rotation_speed

func get_movespeed() -> float:
	return base_movespeed

#region Serialization
func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	var is_copy:bool = resource_path.is_empty()
	serialization.pack(is_copy)
	if !is_copy:
		serialization.pack(resource_path)
		return
	
	serialization.pack(name)
	serialization.pack(prefab)
	serialization.pack(data)
	serialization.pack(base_health)
	serialization.pack(base_mana)
	serialization.pack(main_attribute)
	serialization.pack(base_attack_speed)
	serialization.pack(base_attack_range)
	serialization.pack(base_attack_interval)
	serialization.pack(base_attack_damage)
	serialization.pack(base_magic_resistance)
	serialization.pack(base_strength)
	serialization.pack(base_agility)
	serialization.pack(base_intelligence)
	serialization.pack(base_movespeed)
	serialization.pack(base_rotation_speed)
	serialization.pack(swing_audio)
	serialization.pack(impact_audio)
	serialization.pack(footsteps)
	serialization.pack(attack_animations)
	serialization.pack(portrait)
static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var r_unit = R_Unit.new()
	var is_copy:bool = serialization.unpack()
	
	if !is_copy:
		var res_path = serialization.unpack()
		r_unit = load(res_path)
	else:
		r_unit.name = serialization.unpack()
		r_unit.prefab = serialization.unpack()
		r_unit.data = serialization.unpack()
		r_unit.base_health = serialization.unpack()
		r_unit.base_mana = serialization.unpack()
		r_unit.main_attribute = serialization.unpack()
		r_unit.base_attack_speed = serialization.unpack()
		r_unit.base_attack_range = serialization.unpack()
		r_unit.base_attack_interval = serialization.unpack()
		r_unit.base_attack_damage = serialization.unpack()
		r_unit.base_magic_resistance = serialization.unpack()
		r_unit.base_strength = serialization.unpack()
		r_unit.base_agility = serialization.unpack()
		r_unit.base_intelligence = serialization.unpack()
		r_unit.base_movespeed = serialization.unpack()
		r_unit.base_rotation_speed = serialization.unpack()
		r_unit.swing_audio = serialization.unpack()
		r_unit.impact_audio = serialization.unpack()
		r_unit.footsteps = serialization.unpack()
		r_unit.attack_animations = serialization.unpack()
		r_unit.portrait = serialization.unpack()
	
	serialization.set_result(r_unit)
#endregion
