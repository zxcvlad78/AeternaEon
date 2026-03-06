class_name UnitPortrait extends Node3D

@onready var models:Node3D = get_node("models")

func _ready() -> void:
	if is_instance_valid(Player.get_local_instance()):
		await  Player.get_local_instance().ready
		
		Player.get_local_instance().current_unit_changed.connect(set_model_portrait)

func set_model_portrait(res:R_UnitProperties) -> void:
	##clear
	#if not models.get_children().is_empty():
	for rm_c:Node3D in models.get_children():
		rm_c.queue_free()
	##
	
	if (not res) or (not res.portrait_scene):
		$Placeholder.show()
		return
	$Placeholder.hide()
	
	##add
	var portrait_model:Node3D = res.portrait_scene.instantiate()
	if portrait_model is AnimatedModel:
		portrait_model.target = Player.get_local_instance().current_unit
	
	models.add_child(portrait_model)
	portrait_model.global_position = res.portrait_model_position
	portrait_model.global_rotation = res.portrait_model_rotation
	##
