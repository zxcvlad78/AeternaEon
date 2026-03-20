@static_unload
extends RefCounted
class_name SimusNet

const SERVER_ID: int = 1

enum PACKET {
	RPC,
	RPC_DEFLATE,
	RPC_ZSTD,
	RPC_ASYNC,
	RPC_ASYNC_DELFATE,
	RPC_ASYNC_ZSTD,
	VARIABLE,
}

static func is_network_authority(object: Object) -> bool:
	return get_network_authority(object) == SimusNetConnection.get_unique_id()

static func get_network_authority(object: Object) -> int:
	if is_instance_valid(object):
		return object.get_multiplayer_authority()
	return SimusNetConnection.SERVER_ID
