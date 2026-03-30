class_name R_PointValue extends Resource

@export var points:float = 1.0

func _init(p_points:float = 1.0) -> void:
	SimusNetVars.register(
		self,
		["points"]
	)
	
	points = p_points
