extends Node

func get_leveled_value(level:int, array:Array, default_value:Variant = null) -> Variant:
	if array.is_empty():
		return default_value
	
	if level > array.size():
		return array.back()
	
	var value = array[level]
	
	return value

func get_leveled_value_dict(level:int, dict:Dictionary, array_name:String, default_value:Variant = null) -> Variant:
	var array = dict.get("array_name")
	
	if not array:
		return default_value
	
	if not array is Array:
		return default_value
	
	return get_leveled_value(level, array, default_value)

func get_status_by_id(id:StringName) -> StringName:
	var text:String
	if id == &"stun":
		text = &"Stunned"
	else:
		text = &"Status"
	
	return text
