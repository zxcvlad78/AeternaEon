class_name R_UnitPortrait extends Resource

const DEFAULT_PREFAB = preload("res://src/prefabs/default_portrait.tscn")

@export var prefab:PackedScene = DEFAULT_PREFAB
@export var portrait_model_position:Vector3 = Vector3.ZERO
@export var portrait_model_rotation:Vector3 = Vector3.ZERO
@export var portrait_model_scale:Vector3 = Vector3.ONE

func simusnet_serialize(serialization:SimusNetCustomSerialization) -> void:
	var is_copy:bool = resource_path.is_empty()
	serialization.pack(is_copy)
	if !is_copy:
		serialization.pack(resource_path)
		return
	
	serialization.pack(prefab)
	serialization.pack(portrait_model_position)
	serialization.pack(portrait_model_rotation)
	serialization.pack(portrait_model_scale)
	

static func simusnet_deserialize(serialization:SimusNetCustomSerialization) -> void:
	var r_unit_portrait = R_UnitPortrait.new()
	var is_copy:bool = serialization.unpack()
	
	if !is_copy:
		var res_path = serialization.unpack()
		r_unit_portrait = load(res_path)
	else:
		r_unit_portrait.prefab = serialization.unpack()
		r_unit_portrait.portrait_model_position = serialization.unpack()
		r_unit_portrait.portrait_model_rotation = serialization.unpack()
		r_unit_portrait.portrait_model_scale = serialization.unpack()
	
	serialization.set_result(r_unit_portrait)
