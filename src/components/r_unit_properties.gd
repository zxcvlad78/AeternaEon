class_name R_UnitProperties extends Resource

enum Attribute {
	Strength = 0,
	Agility,
	Intelligence
}

@export var _name:String = "Unit"

@export_category("Variables")
@export var base_health:float = 100.0
@export var base_mana:float = 200.0
@export var main_attribute:Attribute = (0 as Attribute)
@export var base_attack_speed:float = 100
@export var base_attack_interval:float = 1.5
@export var base_attack_damage:float = 50
@export var strength:float = 5.0
@export var agility:float = 5.0
@export var intelligence:float = 5.0
@export var base_movespeed:float = 300.0
@export var base_rotation_speed:float = 10.0
@export var base_magic_resistance:float = 25.0

@export_category("Resources")
@export var attack_swing_sounds:Array[AudioStream] = []
@export var attack_hit_sounds:Array[AudioStream] = []
@export var footsteps_sounds:Array[AudioStream] = []

@export_category("Portrait")
@export var portrait_scene:PackedScene
@export var portrait_model_position:Vector3 = Vector3.ZERO
@export var portrait_model_rotation:Vector3 = Vector3.ZERO
