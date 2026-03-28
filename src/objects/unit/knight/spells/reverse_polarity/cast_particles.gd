extends W_Particles

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	super()
	
	if not spell:
		return
	
	var mesh = mesh_instance_3d.mesh
	if mesh is SphereMesh:
		mesh.radius = spell.res.get_radius()
