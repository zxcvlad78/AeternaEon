extends W_Particles

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	$blood.emitting = false
