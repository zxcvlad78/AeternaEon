class_name Unit extends W_LivingEntity

signal update()

@onready var ct_health:CT_Health = SD_ECS.find_first_component_by_script(self, [CT_Health])
@onready var ct_mana:CT_Mana = SD_ECS.find_first_component_by_script(self, [CT_Mana])

@onready var ct_movement:CT_Movement = SD_ECS.find_first_component_by_script(self, [CT_Movement])
@onready var ct_attack:CT_Attack = SD_ECS.find_first_component_by_script(self, [CT_Attack])
@onready var spell_machine:SpellMachine = SD_ECS.find_first_component_by_script(self, [SpellMachine])

@onready var unit_orders:UnitOrders = SD_ECS.find_first_component_by_script(self, [UnitOrders])
@onready var unit_effects:UnitEffects = SD_ECS.find_first_component_by_script(self, [UnitEffects])

@onready var mesh_cast_range:MeshCastRange = SD_ECS.find_first_component_by_script(self, [MeshCastRange])

var resource:R_Unit = R_Unit.new():
	set(val):
		resource = val
		
		resource.base_health_changed.connect(update_health)
		resource.base_strength_changed.connect(update_health)
		
		resource.base_mana_changed.connect(update_mana)
		resource.base_intelligence_changed.connect(update_mana)

@export var state_machine:SD_NodeStateMachine
@export var animated_model:AnimatedModel

var unit_velocity:Vector3
var blend_position:Vector2

func get_unit_height() -> float:
	if animated_model:
		var mesh_node = animated_model.find_child("*", true, false)
		if mesh_node is MeshInstance3D:
			return mesh_node.get_aabb().size.y * animated_model.scale.y
	return 2.0

func _init() -> void:
	var enabled = not Engine.is_editor_hint()
	set_process(enabled)
	set_physics_process(enabled)
	set_process_input(enabled)

func _ready() -> void:
	SimusNetVars.register(
		self,
		["velocity"], 
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication().flag_tickrate(16.0)
	)
	
	update_hero()
	ct_health.apply_replenish(R_PointValue.new(ct_health.max_points))
	ct_mana.apply_replenish(R_PointValue.new(ct_mana.max_points))

func is_disabled() -> bool:
	if unit_effects.find_effect_by_id(&"stun"):
		return true
	
	return false

func update_hero() -> void:
	update_health()
	update_mana()

func update_health() -> void:
	if not resource or not ct_health:
		return
	ct_health.max_points = resource.get_max_health()

func update_mana() -> void:
	if not resource or not ct_mana:
		return
	ct_mana.max_points = resource.get_max_mana()

func _physics_process(_delta: float) -> void:
	unit_velocity = velocity.normalized() * transform.basis
	blend_position = Vector2(unit_velocity.x, -unit_velocity.z)
