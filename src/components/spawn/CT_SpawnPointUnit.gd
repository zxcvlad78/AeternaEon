@tool
class_name CT_SpawnPointUnit extends CT_SpawnPoint

@export var root:Node3D

@export var unit:R_Unit

@export var spawn_at_ready:bool = true

func _ready() -> void:
	super()
	if spawn_at_ready:
		spawn()

func _spawn() -> void:
	AE.spawn_unit(unit, root, global_position)
