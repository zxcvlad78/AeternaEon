extends Node

##sex
func play_global(stream:AudioStream, pos:Vector3 = Vector3.ZERO, audio_player:AudioStreamPlayer3D = AudioStreamPlayer3D.new()):
	get_tree().root.add_child(audio_player)
	audio_player.stream = stream
	audio_player.global_position = pos
	audio_player.play()
