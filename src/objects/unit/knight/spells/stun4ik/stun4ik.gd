extends Spell

func _spawn_partilces(particles:R_Particles) -> void:
	s_Particles.spawn(self, particles, last_target.global_position)

func on_cast(target:Variant = null) -> void:
	if multiplayer.is_server():
		
		var base_damage:Array = res.data.get("damage", [])
		if base_damage.is_empty():
			return
		
		var damage = res.get_leveled_value(base_damage)
		
		if target is Unit:
			target.ct_health.apply_diminish(R_PointValue.new(damage))
