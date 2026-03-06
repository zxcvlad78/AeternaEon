extends Node

func spawn(spell:Spell, particles:R_Particles, global_pos:Vector3 = Vector3.ZERO, node:Node3D = null) -> void:
	if not is_instance_valid(spell):
		return
	if not particles:
		return
	if not particles.prefab:
		return
	
	var instance = particles.prefab.instantiate()
	instance.spell = spell
	
	if instance is W_Particles:
		if node:
			node.add_child(instance)
		else:
			get_tree().root.add_child(instance)
		
		instance.global_position = global_pos
	else:
		push_error("[s_Particlles] Particles prefab is not W_Particles: %s" % particles)
	
	
	get_tree().create_timer(particles.life_time).timeout.connect(
		instance.queue_free)
