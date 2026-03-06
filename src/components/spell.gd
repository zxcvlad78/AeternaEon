class_name Spell extends Node3D

signal precast_start(by:BaseUnit)
signal casted(by:BaseUnit)
signal cooldown_started(time:float)

@export var resource:R_Spell
@export var spell_level:int = 0
@export var custom_action_key:String = ""
@onready var spell_container:SpellContainer = get_parent() 

var cooldown:float = 0.000

var should_cast:bool = false
var current_target:Variant

func _ready() -> void:
	name = resource._name

func _spawn_precast_particles() -> void:
	s_Particles.spawn(self, resource.particles.precast, spell_container.unit.global_position)

func _spawn_cast_particles() -> void:
	s_Particles.spawn(self, resource.particles.cast, spell_container.unit.global_position)

func can_cast(target: Variant = null) -> bool:
	if spell_container.unit.mana_component.mana_points >= get_mana_cost():
		if is_cooldown():
			return false
	
	return true

func can_reach(target:Variant) -> bool:
	if resource.target_type == resource.Target.NO_TARGET:
		return true
	
	var distance_to_target:float = 0.0
	var unit_pos:Vector3 = spell_container.unit.global_position
	if target is Node3D:
		distance_to_target = unit_pos.distance_to(
			target.global_position)
	elif target is Vector3:
		distance_to_target = unit_pos.distance_to(
			target)
	else:
		return false
	
	if distance_to_target > get_cast_range():
		return false
	
	return true

func precast(target: Variant = null) -> void:
	if spell_container.is_casting():
		return
	if not can_cast(target):
		return
	current_target = target
	if not can_reach(target):
		should_cast = true
		return
	
	should_cast = false
	
	spell_container.current_cast = self
	if resource.precast_time == 0.0:
		cast(target)
	else:
		get_tree().create_timer(resource.precast_time).timeout.connect(precast_finished.bind(target))
	
	
	spell_container.unit.controllable.stop()
	precast_start.emit(spell_container.unit)
	spell_container.set_casting(true)
	spell_container.unit.model_root.play_tree_oneshot_by_array(resource.swing_animation_names)
	_spawn_precast_particles()
	GlobalAudioPlayer.create_3d(
		GlobalAudioPlayer,
		resource.precast_sound,
		"sfx",
		0.0,
		spell_container.unit.global_position
		).play()

func precast_finished(target: Variant = null) -> void:
	if not spell_container.is_casting():
		return
	
	spell_container.set_casting(false)
	cast(target)
 
func cast(target: Variant = null) -> void:
	spell_container.unit.mana_component.apply_diminish(get_mana_cost())
	start_cooldown()
	current_target = target
	if resource.cast_sound:
		GlobalAudioPlayer.create_3d(
			GlobalAudioPlayer,
			resource.cast_sound,
			"sfx",
			0.0,
			spell_container.unit.global_position).play()
	
	spell_container.current_cast = null
	casted.emit(spell_container.unit)
	spell_container.unit.model_root.play_tree_oneshot_by_array(resource.backswing_animation_names)
	_spawn_cast_particles()


func get_res_value(array:Array[float]) -> float:
	if array.is_empty():
		return 0.0
	
	if spell_level <= array.size():
		return array[spell_level]
	
	return resource.mana_cost[resource.mana_cost.size()]

func is_cooldown() -> bool:
	return cooldown > 0.0

func get_cooldown() -> float:
	return get_res_value(resource.cooldown)

func get_radius() -> float:
	return get_res_value(resource.radius)

func get_cast_range() -> float:
	return get_res_value(resource.cast_range)

func start_cooldown() -> void:
	cooldown = get_cooldown()
	cooldown_started.emit(cooldown)

func get_mana_cost() -> float:
	return get_res_value(resource.mana_cost)

func can_upgrade() -> bool:
	return (spell_container.unit.skill_points > 0) and (spell_container.unit.level > resource.required_level)  \
		and (spell_level < resource.max_level)

func upgrade() -> void:
	if can_upgrade():
		spell_level += 1
		spell_container.unit.skill_points -= 1

func create_radius_shape() -> CylinderShape3D:
	var new_shape:CylinderShape3D = CylinderShape3D.new()
	new_shape.height = 100.0
	new_shape.radius = get_radius()
	
	
	return new_shape

func _process(delta: float) -> void:
	if cooldown > 0.000:
		cooldown -= 1.000 * delta
	
	if should_cast and current_target:
		spell_container.unit.controllable.goto_target(current_target)
		precast(current_target)
	
