extends RefCounted
class_name SimusNetRPCConfigHandler

var _list_by_name: Dictionary[String, SimusNetRPCConfig] = {}

var _object: Object : get = get_object

const META: StringName = "SimusNetRPCConfigHandler"

func get_object() -> Object:
	if !is_instance_valid(_object):
		_object = null
	return _object

static func get_or_create(object: Object) -> SimusNetRPCConfigHandler:
	if object.has_meta(META):
		var cfg: SimusNetRPCConfigHandler = object.get_meta(META)
		if is_instance_valid(cfg):
			if cfg.get_object():
				if cfg.get_object() == object:
					return cfg
	
	var handler := SimusNetRPCConfigHandler.new()
	handler._object = object 
	object.set_meta(META, handler)
	handler._initialize()
	return handler

func _initialize() -> void:
	SimusNetConnection.connect_network_node_callables(
		self,
		_network_ready,
		_network_disconnect,
		_network_not_connected
	)

func _network_ready() -> void:
	for c_name in _list_by_name:
		SimusNetMethods.cache_by_name(c_name)
		_list_by_name[c_name]._network_ready(self)

func _network_disconnect() -> void:
	for c_name in _list_by_name:
		_list_by_name[c_name]._network_disconnect(self)

func _network_not_connected() -> void:
	pass
