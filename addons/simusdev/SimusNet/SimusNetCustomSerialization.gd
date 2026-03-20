extends RefCounted
class_name SimusNetCustomSerialization

#methods in objects
func simusnet_serialize(serialization: SimusNetCustomSerialization) -> void:
	pass

static func simusnet_deserialize(serialization: SimusNetCustomSerialization) -> void:
	pass

const METHOD_SERIALIZE: String = "simusnet_serialize"
const METHOD_DESERIALIZE: String = "simusnet_deserialize"

var _data: Variant
var _result: Variant
var _result_def: Variant

static func find_base_script(script: Script, recursive: bool = true) -> Script:
	if not script:
		return script
	
	var base: Script = script.get_base_script()
	
	if !base:
		return script
	
	if recursive:
		return find_base_script(script.get_base_script())
	return base

func set_data(new: Variant) -> SimusNetCustomSerialization:
	_data = new
	return self

func get_data() -> Variant:
	return _data

func set_result(new: Variant) -> SimusNetCustomSerialization:
	_result = new
	return self

func get_result() -> Variant:
	return _result

func pack(value: Variant) -> SimusNetCustomSerialization:
	if !_data is Array:
		_data = []
	_data.append(value)
	return self

func unpack() -> Variant:
	if _data is Array:
		return _data.pop_front()
	return null
