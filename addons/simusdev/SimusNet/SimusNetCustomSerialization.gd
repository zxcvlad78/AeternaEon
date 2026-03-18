extends RefCounted
class_name SimusNetCustomSerialization

#methods in objects

#func simusnet_serialize(serialization: SimusNetCustomSerialization) -> void:
	#pass
#

#static func simusnet_deserialize(serialization: SimusNetCustomSerialization) -> void:
	#pass

const METHOD_SERIALIZE: String = "simusnet_serialize"
const METHOD_DESERIALIZE: String = "simusnet_deserialize"

var _data: Variant
var _result: Variant

func _net_serialize(owner: Object) -> Array:
	var script: Script = owner.get_script()
	return [
		_data,
		ResourceUID.path_to_uid(script.resource_path).replacen("uid://", "")
	]

static func _net_deserialize(data: Array) -> Variant:
	var result: SimusNetCustomSerialization = SimusNetCustomSerialization.new()
	if data.is_empty():
		printerr("serialized data array is empty!")
		return result
	
	var path: String = "uid://" + data[1]
	var static_script: Script = load(path)
	if !static_script:
		printerr("failed to load script %s!" % [path])
		return result
	
	result._data = data[0]
	
	static_script.call(METHOD_DESERIALIZE, result)
	return result._result

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

func data_serialize_and_append(value: Variant) -> SimusNetCustomSerialization:
	if !_data is Array:
		_data = []
	_data.append(SimusNetSerializer.parse(value))
	return self

func data_append(value: Variant) -> SimusNetCustomSerialization:
	if !_data is Array:
		_data = []
	_data.append(value)
	return self

func data_get() -> Variant:
	if _data is Array:
		return _data.pop_front()
	return null

func data_deserialize_and_get() -> Variant:
	if _data is Array:
		return SimusNetDeserializer.parse(_data.pop_front())
	return null
