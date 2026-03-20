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
	if not root:
		return
	if not unit:
		return
	if not unit.prefab:
		return
	
	var inst = unit.prefab.instantiate()
	inst.set("res", unit)
	root.add_child(inst)
	
	if inst is Node3D:
		inst.global_position = self.global_position
