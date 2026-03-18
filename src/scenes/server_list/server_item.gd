extends Button

@onready var name_label: Label = $Label
@onready var description_label: Label = $Label2
@onready var icon_texture_rect: TextureRect = $TextureRect


var server_listener:SimusNetServerListener
var server_info:Dictionary

func _ready() -> void:
	if not server_info:
		return
	if not is_instance_valid(server_listener):
		return
	
	server_listener.server_removed.connect(_server_removed)
	
	name_label.text = server_info.get("name", "Unknown Server")
	description_label.text = server_info.get("description", "Empty Description")
	
	
	if server_info.has("texture"):
		icon_texture_rect.texture = server_info["texture"]

func _pressed() -> void:
	var ip = server_info.get("ip", "")
	var port = server_info.get("port", 8080)
	
	Network.connect_to_server(ip, port)

func _server_removed(ip:String) -> void:
	if ip == server_info.get("ip", ""):
		queue_free()
