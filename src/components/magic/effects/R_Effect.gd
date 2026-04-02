class_name R_Effect extends Resource

@export var id: StringName = "base_effect"
@export var icon: Texture

@export var data:Dictionary = {}
@export var effect_script: Script


@export_group("Settings")
@export var is_debuff:bool = false
@export var stackable:bool = false
@export var dispellable:bool = true
@export var breakable:bool = true
@export var duration:Array[float] = []


@export_group("StatusBar", "statusbar_")
@export var statusbar_visible:bool = false
@export var statusbar_text:StringName = &""

var level:int = 0

#region Serialization
func simusnet_serialize(serializer:SimusNetCustomSerialization) -> void:
	var is_copy:bool = resource_path.is_empty()
	serializer.pack(is_copy)
	if !is_copy:
		serializer.pack(resource_path)
		return
	
	serializer.pack(id)
	serializer.pack(icon)
	serializer.pack(effect_script)
	serializer.pack(is_debuff)
	serializer.pack(stackable)
	serializer.pack(dispellable)
	serializer.pack(breakable)
	serializer.pack(duration)
	serializer.pack(data)
	serializer.pack(statusbar_visible)
	serializer.pack(statusbar_text)

static func simusnet_deserialize(serializer:SimusNetCustomSerialization) -> void:
	var r_effect = R_Effect.new()
	var is_copy:bool = serializer.unpack()
	
	if !is_copy:
		var res_path = serializer.unpack()
		r_effect = load(res_path)
	else:
		r_effect.id = serializer.unpack()
		r_effect.icon = serializer.unpack()
		r_effect.effect_script = serializer.unpack()
		r_effect.is_debuff = serializer.unpack()
		r_effect.stackable = serializer.unpack()
		r_effect.dispellable = serializer.unpack()
		r_effect.breakable = serializer.unpack()
		r_effect.duration = serializer.unpack()
		r_effect.data = serializer.unpack()
		r_effect.statusbar_visible = serializer.unpack()
		r_effect.statusbar_text = serializer.unpack()
	
	serializer.set_result(r_effect)
#endregion

func get_duration() -> float:
	return AE.get_leveled_value(level, duration)

func is_permanent() -> bool:
	if duration.is_empty():
		return true
	if get_duration() < 0.0:
		return true
	
	return false

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
