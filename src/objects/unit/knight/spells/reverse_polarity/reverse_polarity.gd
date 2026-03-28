extends Spell

var area:Area3D
var collision_shape:CollisionShape3D

func _ready() -> void:
	super()
	
	if not multiplayer.is_server():
		return
	
	area = Area3D.new()
	area.monitorable = false
	area.input_ray_pickable = false
	add_child(area)
	
	collision_shape = CollisionShape3D.new()
	collision_shape.shape = CylinderShape3D.new()
	collision_shape.shape.height = 2.0
	area.add_child(collision_shape)

func _local_precast(target:Variant = null) -> void:
	super(target)
	
	if multiplayer.is_server():
		if not res:
			return 
		collision_shape.shape.radius = res.get_radius()

func on_cast(target:Variant = null) -> void:
	if not multiplayer.is_server():
		return
	
	var caster = spell_machine.unit
	var pull_position = caster.global_position - caster.global_transform.basis.z * (caster.scale * 0.8)
	
	for body in area.get_overlapping_bodies():
		if body == caster: continue
		if body is Unit:
			_apply_rp_effects(body, pull_position)

func _apply_rp_effects(target:Unit, pull_pos:Vector3) -> void:
	target.global_position = pull_pos
	
	target.look_at(spell_machine.unit.global_position)
	target.rotate_y(PI)
	
	var base_stun_duration = res.data.get("stun_duration", Array([]))
	var base_damage = res.data.get("damage", Array([]))
	
	var stun_duration = res.get_leveled_value(base_stun_duration)
	var damage = res.get_leveled_value(base_damage)
	
	var res_dmg = R_PointValue.new(damage)
	
	target.ct_health.apply_diminish(res_dmg)
	#print(target.ct_health.points)
