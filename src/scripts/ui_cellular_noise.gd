class_name UI_CellularNoise extends TextureRect

var time: float = 0.0

func _ready() -> void:
	material = material.duplicate()
	material = (material as ShaderMaterial)
	
	material.set_shader_parameter("noise_seed", randi_range(-1000, +1000))

func _process(delta: float) -> void:
	if material:
		time += delta 
		
		time = fmod(time, 10000.0) 
		
		material.set_shader_parameter("time", time)
