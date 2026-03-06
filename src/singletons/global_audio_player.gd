extends Node3D


func create_2d(parent:Node) -> AudioStreamPlayer2D:
	return null

func create_3d(parent:Node, stream:AudioStream, bus:String="Master", volume_db:float = 0.0, global_position:Vector3 = Vector3.ZERO, free_at_finish:bool = true) -> AudioStreamPlayer3D:
	if parent and is_instance_valid(parent):
		var new_audio_player:AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		if free_at_finish: new_audio_player.finished.connect(new_audio_player.queue_free)
		new_audio_player.stream = stream
		new_audio_player.bus = bus
		new_audio_player.volume_db = volume_db
		parent.add_child(new_audio_player)
		if global_position:
			new_audio_player.global_position = global_position
		return new_audio_player
	
	return null
