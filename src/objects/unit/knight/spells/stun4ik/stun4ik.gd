extends Spell

func _spawn_partilces(particles:R_Particles) -> void:
	if not last_target:
		return
	
	if last_target is Unit:
		
		var pos = last_target.global_position
		pos.y += last_target.get_unit_height()
		
		s_Particles.spawn(self, particles, pos)

func on_cast(target:Variant = null) -> void:
	if multiplayer.is_server():
		var damage = AE.get_leveled_value_dict(
			res.level,
			res.spell_data,
			"damage",
			0.0
			)
		
		if target is Unit:
			target.ct_health.apply_diminish(R_PointValue.new(damage))
