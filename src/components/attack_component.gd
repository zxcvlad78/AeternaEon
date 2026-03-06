class_name AttackComponent extends Node

@export var animation_library_name:StringName = "library"
@export var animation_names:Array[StringName]

@export_category("Settings")
@export var distance_treshold:float = 2.0

@onready var unit:BaseUnit = get_parent()

var should_attack:bool = false
var current_target:Node3D

var cooldown_timer:Timer = Timer.new()

func _ready() -> void:
	randomize()
	
	if is_instance_valid(Player.get_local_instance()):
		Player.get_local_instance().action_cancel.connect(cancel_attack)
	pass
	
	if is_instance_valid(unit.model_root):
		unit.model_root.hit.connect(deal_damage)

func cancel_attack() -> void:
	if unit.model_root:unit.model_root.stop_tree_oneshot()
	current_target = null
	should_attack = false

func attack(target: Node3D) -> void:
	print("new target: %s" % str(target))
	should_attack = true
	current_target = target

func swing() -> void:
	unit.state_machine.switch_by_name("attacking")

	if not unit.unit_resource.attack_swing_sounds.is_empty():
		GlobalAudioPlayer.create_3d(unit, unit.unit_resource.attack_swing_sounds.pick_random()).play()
	
	
	if is_instance_valid(unit.model_root):
		unit.model_root.set_attack_animation_speed( unit.get_attack_speed() / 100.0 )
		unit.model_root.play_tree_oneshot_by_name(animation_names.pick_random())
		

func deal_damage() -> void:
	if is_instance_valid(current_target) and current_target is BaseUnit:
		current_target.health_component.apply_damage( unit.get_attack_damage() )
		
		if not unit.unit_resource.attack_hit_sounds.is_empty():
			GlobalAudioPlayer.create_3d(unit, unit.unit_resource.attack_hit_sounds.pick_random()).play()

func can_attack() -> bool:
	if unit.model_root:
		return not unit.model_root.is_tree_oneshot_playing()
	return false

func _process(_delta: float) -> void:
	if should_attack and can_attack() and current_target:
		if unit.global_position.distance_to(current_target.global_position) > distance_treshold:
			unit.controllable.goto(current_target.global_position)
		else:
			swing()
