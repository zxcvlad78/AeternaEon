class_name UnitOrders extends Node

@export var unit:Unit

func _ready() -> void:
	SD_ECS.append_to(unit, self)
	
	SimusNetRPC.register(
		[_server_hold_position],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func hold_position() -> void:
	SimusNetRPC.invoke_on_server(_server_hold_position)

func _server_hold_position() -> void:
	unit.ct_movement.stop()
	unit.spell_machine.interrupt_cast()
