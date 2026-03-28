class_name Unit extends W_LivingEntity

@onready var ct_health:CT_Health = SD_ECS.find_first_component_by_script(self, [CT_Health])
@onready var ct_mana:CT_Mana = SD_ECS.find_first_component_by_script(self, [CT_Mana])

@onready var ct_movement:CT_Movement = SD_ECS.find_first_component_by_script(self, [CT_Movement])
@onready var spell_machine:SpellMachine = SD_ECS.find_first_component_by_script(self, [SpellMachine])

@onready var unit_orders:UnitOrders = SD_ECS.find_first_component_by_script(self, [UnitOrders])

var resource:R_Unit = R_Unit.new():
	set(val):
		resource = val#.duplicate()

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
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication()
	)

func _physics_process(_delta: float) -> void:
	unit_velocity = velocity.normalized() * transform.basis
	blend_position = Vector2(unit_velocity.x, -unit_velocity.z)

func _process(_delta: float) -> void:
	if not SimusNetConnection.is_server():
		return

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var player = PlayerCamera.i()
				if not is_instance_valid(player):
					return
				
				player.select_unit(self)
