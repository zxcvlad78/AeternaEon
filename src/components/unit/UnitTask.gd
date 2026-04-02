class_name UnitTask extends RefCounted

signal finished

var unit:Unit
var target:Variant

var icon:Texture

func _init(_unit:Unit = null, _target:Variant = null):
	SimusNetIdentity.register(self)
	SimusNetVars.register(
		self,
		[
			"unit",
			"target",
		]
		
	)
	
	unit = _unit
	target = _target

func get_icon() -> Texture:
	if icon:
		return icon
	return _get_icon()

func _get_icon() -> Texture:
	return load("res://src/textures/grass.jpg")

func start() -> void:
	pass

func cancel() -> void:
	pass

func on_finish() -> void:
	finished.emit()


#region Serialization
func simusnet_serialize(serializer:SimusNetCustomSerialization) -> void:
	serializer.pack(get_script())
	var id:SimusNetIdentity = SimusNetIdentity.register(self)
	serializer.pack(id.get_unique_id())
	
	serializer.pack(unit)
	serializer.pack(target)
	serializer.pack(icon)

static func simusnet_deserialize(serializer:SimusNetCustomSerialization) -> void:
	var script:Script = serializer.unpack()
	
	var task:UnitTask = script.new()
	SimusNetIdentity.register(task, serializer.unpack())
	
	task.unit = serializer.unpack()
	task.target = serializer.unpack()
	task.icon = serializer.unpack()
	
	serializer.set_result(task)
#endregion
