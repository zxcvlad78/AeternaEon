extends Node

func spawn(spell:Spell, particles:R_Particles, pos:Vector3) -> void:
	if not particles:
		return
	if not particles.prefab:
		return
	var new_pareticles = particles.prefab.instantiate()
	
	if new_pareticles is W_Particles:
		get_tree().root.add_child(new_pareticles)
		new_pareticles.global_position = pos
		
		get_tree().create_timer(particles.life_time).timeout.connect(
			func():
				if is_instance_valid(new_pareticles): new_pareticles.queue_free()
		)
		
		var channel = spell.spell_machine.spell_channeling
		if channel:
			if channel.spell == spell:
				channel.finished.connect(
					func(success:bool):
						if not success:
							if is_instance_valid(new_pareticles): new_pareticles.queue_free()
				)
