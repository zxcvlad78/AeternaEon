extends Node

func _ready() -> void:
	SimusNetRPC.register(
		[
			play_global,
		],
		SimusNetRPCConfig.new().flag_mode_server_only()
	)

func play_global_from_server(stream:AudioStream, pos:Vector3 = Vector3.ZERO, free_on_finish:bool = true, properties:Dictionary = {}) -> void:
	
	SimusNetRPC.invoke_all(
		play_global,
		stream,
		pos,
		free_on_finish,
		properties,
	)

##sex
func play_global(stream:AudioStream, pos:Vector3 = Vector3.ZERO, free_on_finish:bool = true, properties:Dictionary = {}):
	var audio_player = AudioStreamPlayer3D.new()
	
	for property in properties.keys():
		audio_player.set(property, properties.get(property))
	
	get_tree().root.add_child(audio_player)
	
	audio_player.stream = stream
	audio_player.global_position = pos
	audio_player.play()
	
	if free_on_finish:
		audio_player.finished.connect(audio_player.queue_free)
