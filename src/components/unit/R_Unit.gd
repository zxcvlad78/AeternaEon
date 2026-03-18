class_name R_Unit extends Resource

enum Attribute {
	STRENGTH = 0,
	AGILITY,
	INTELLIGENCE
}

@export var name:String = "Unit"

@export var prefab:PackedScene

@export_category("Variables")
@export var base_health:float = 100.0
@export var base_mana:float = 200.0
@export var main_attribute:Attribute = Attribute.STRENGTH

@export var base_attack_speed:float = 100
@export var base_attack_interval:float = 1.5
@export var base_attack_damage:float = 50

@export var base_magic_resistance:float = 25.0

@export var strength:float = 5.0
@export var agility:float = 5.0
@export var intelligence:float = 5.0

@export var base_movespeed:float = 3.0
@export var base_rotation_speed:float = 22.0

func get_health_regen() -> float:
	return strength * 0.09
func get_max_health() -> float:
	return base_health + strength * 22

func get_mana_regen() -> float:
	return intelligence * 0.05
func get_max_mana() -> float:
	return base_mana + intelligence * 12

func get_attack_speed() -> float:
	return (((base_attack_speed + agility) * 0.6) * base_attack_interval)

func get_attack_damage() -> float:
	if main_attribute == Attribute.STRENGTH:
		return base_attack_damage + strength
	elif main_attribute == Attribute.AGILITY:
		return base_attack_damage + agility
	elif main_attribute == Attribute.INTELLIGENCE:
		return base_attack_damage + intelligence
	return 0.0

func get_rotation_speed() -> float:
	return base_rotation_speed

func get_movespeed() -> float:
	return base_movespeed
