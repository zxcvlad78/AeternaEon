class_name BaseUnit extends CharacterBody3D

@onready var health_component:HealthComponent = get_node("HealthComponent")
@onready var mana_component:ManaComponent = get_node("ManaComponent")

@onready var controllable:Controllable = get_node("Controllable")
@onready var navigation_agent:NavigationAgent3D = get_node("NavigationAgent3D")

@onready var current_unit_mesh:MeshInstance3D = get_node("current_unit_mesh")
@onready var spell_container:SpellContainer = get_node("SpellContainer")
@onready var state_machine:SD_NodeStateMachine = get_node("StateMachine")

@onready var attack_component:AttackComponent = get_node("AttackComponent")

@onready var debug_node:Node3D = get_node("Debug")
@onready var debug_mana_label:Label3D = debug_node.get_node("mana")
@onready var debug_health_label:Label3D = debug_node.get_node("health")

@onready var chosed_spell_cast_range: MeshInstance3D = $chosed_spell_cast_range


@export var unit_resource:R_UnitProperties
@export var model_root:AnimatedModel

var unit_velocity:Vector3 = Vector3.ZERO
var blend_position:Vector2 = Vector2.ZERO
var level:int = 1
var experience:float = 0.0
var skill_points:int = 1
var strength:float = 1.0
var agility:float = 1.0
var intelligence:float = 1.0
var health_regen:float = 1.0
var mana_regen:float = 1.0
var magic_resistance:float = 25.0

var current_speed:float = 0.0
var rotation_speed:float = 1.0

var attack_interval:float = 0.0
var attack_speed:float = 1.0


func _ready() -> void:
	GameSettings.debug_mode_changed.connect(_update_debug)
	_update_debug()
	
	if unit_resource:
		strength = unit_resource.strength
		agility = unit_resource.agility
		intelligence = unit_resource.intelligence
		rotation_speed = unit_resource.base_rotation_speed
		attack_interval = unit_resource.base_attack_interval
		attack_speed = unit_resource.base_attack_speed
		
		all_update()
	apply_full_regen()
	
	Player.get_local_instance().current_unit_changed.connect(on_player_current_unit_chaned)
	spell_container.on_spell_chosed.connect(_on_spell_chosed)

func apply_full_regen() -> void:
	health_component.apply_full_regen()
	mana_component.apply_full_regen()

func all_update() -> void:
	update_health()
	update_mana()

func update_health() -> void:
	if is_instance_valid(health_component) and unit_resource:
		health_regen = (strength * 0.09)
		health_component.max_health_points = unit_resource.base_health + strength * 22

func update_mana() -> void:
	if is_instance_valid(mana_component) and unit_resource:
		mana_regen = (intelligence * 0.05)
		mana_component.max_mana_points = unit_resource.base_mana + intelligence * 12

func on_player_current_unit_chaned(_unit_res:R_UnitProperties) -> void:
	if is_instance_valid(Player.get_local_instance()):
		current_unit_mesh.visible = Player.get_local_instance().current_unit == self
		
		if is_instance_valid(current_unit_mesh.get_node("AnimationPlayer")):
			current_unit_mesh.get_node("AnimationPlayer").play("animation")

func get_attack_speed() -> float:
	if is_instance_valid(Player.get_local_instance()):
		return (attack_speed + (agility * 0.6) ) * attack_interval 
	return 0.0

func get_attack_damage() -> float:
	if is_instance_valid(Player.get_local_instance()):
		if unit_resource.main_attribute == unit_resource.Attribute.Strength:
			return (unit_resource.base_attack_damage + strength)
		elif unit_resource.main_attribute == unit_resource.Attribute.Agility:
			return (unit_resource.base_attack_damage + agility)
		elif unit_resource.main_attribute == unit_resource.Attribute.Intelligence:
			return (unit_resource.base_attack_damage + intelligence)
	return 0.0

func get_movespeed() -> float:
	if is_instance_valid(Player.get_local_instance()):
		return (unit_resource.base_movespeed / 100) #потом будут плюсоваться шмотки и баффы
	return 0.0

func _physics_process(_delta: float) -> void:
	unit_velocity = velocity.normalized() * transform.basis
	blend_position = Vector2(unit_velocity.x, -unit_velocity.z)

func _process(delta: float) -> void:
	update_health()
	update_mana()
	_update_debug()
	
	health_component.apply_health(health_regen * delta)
	mana_component.apply_replenish(mana_regen * delta)

func _update_debug() -> void:
	debug_mana_label.text = str(snapped(mana_component.mana_points, .1))
	debug_health_label.text = str(snapped(health_component.health_points, .1))

func _on_spell_chosed() -> void:
	print(spell_container.chosed_spell)
	if not spell_container.chosed_spell:
		hide_spell_cast_range()
		return
	show_spell_cast_range()

func show_spell_cast_range() -> void:
	chosed_spell_cast_range.show()
	var range = spell_container.chosed_spell.get_cast_range()
	chosed_spell_cast_range.scale = Vector3(range, 1, range)

func hide_spell_cast_range() -> void:
	chosed_spell_cast_range.hide()

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not is_instance_valid(Player.get_local_instance().current_unit) or Player.get_local_instance().current_unit == self:
		return
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
				Player.get_local_instance().current_unit.attack_component.attack(self)
