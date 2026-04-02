extends Control

@onready var icon: TextureRect = $Icon

var task:UnitTask

func _ready() -> void:
	if not task:
		return
	
	_update()

func _update() -> void:
	if is_instance_valid(task):
		icon.texture = task.get_icon()
		apply_size.call_deferred()

func apply_size(idx:int = get_index()) -> void:
	if is_inside_tree():
		if idx == 0:
			custom_minimum_size = Vector2(52, 52)
		else:
			custom_minimum_size = Vector2(42, 42)
		
		size = custom_minimum_size
