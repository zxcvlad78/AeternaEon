class_name SpellReversePolarity extends Spell

var stun_time:Array[float] = [2.5, 3, 3,5]

@onready var prefab_radius_area:PackedScene = preload("res://src/scenes/prefabs/radius_area.tscn")
@onready var radius_area = prefab_radius_area.instantiate()

func _ready() -> void:
	super()
	add_child(radius_area)
	_update()

func upgrade() -> void:
	super()
	_update()

func _update() -> void:
	radius_area.get_node("collision_shape").shape = create_radius_shape()

func _spawn_cast_particles() -> void:
	var pos:Vector3 = spell_container.unit.global_position
	pos.y += 0.5
	s_Particles.spawn(self, resource.particles.cast, pos)

func cast(target: Variant = null) -> void:
	super()
	
	for body in radius_area.get_overlapping_bodies():
		if body is BaseUnit:
			body.global_position = spell_container.unit.global_position
