extends Node

func spawn(spell:Spell, particles:R_Particles, pos:Vector3) -> void:
	if not particles:
		return
	if not particles.prefab:
		return
	var new_particles = particles.prefab.instantiate()
	
	if new_particles is W_Particles:
		new_particles.spell = spell
		
		get_tree().root.add_child(new_particles)
		new_particles.global_position = pos
		
		get_tree().create_timer(particles.life_time).timeout.connect(
			_free_particles.bind(new_particles)
		)
		
		var channel = spell.spell_machine.spell_channeling
		print(channel)
		if channel:
			if channel.spell == spell:
				channel.finished.connect(
					func(success:bool):
						if not success:
							_free_particles(new_particles))

func _free_particles(particles:Node) -> void:
	if is_instance_valid(particles):
		particles.queue_free()
