extends W_Particles

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super()
	var mesh = mesh_instance_3d.mesh
	if mesh is TubeTrailMesh:
		mesh.radius = spell.get_radius()
