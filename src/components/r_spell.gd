class_name R_Spell extends Resource

enum Target {
	NO_TARGET = 0,
	UNIT_TARGET,
	POINT_TARGET,
}

@export var _name:StringName = "spell"
@export var _icon:Texture
@export var description: String = ""

@export_category("Behavior")
@export var target_type: Target = Target.NO_TARGET
@export var custom_prefab:PackedScene
@export var particles:R_ParticlesSettings
@export var precast_sound:AudioStream
@export var cast_sound:AudioStream
@export var precast_time:float = 0.0
@export var cast_range: Array[float] = [0]
@export var cast_point: float = 0.0 
@export var radius: Array[float] = []
#@export var backswing: float = 0.0


@export_category("Animation")
@export var swing_animation_names:Array[StringName]
@export var backswing_animation_names:Array[StringName]

@export_category("Cooldown")
@export var cooldown: Array[float] = [0]

@export_category("Mana Cost")
@export var mana_cost: Array[float] = [0]

@export_category("Leveling")
@export var max_level: int = 4
@export var required_level: int = 1
