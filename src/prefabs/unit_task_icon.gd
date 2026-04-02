extends Control

@onready var icon: TextureRect = $Icon

var task:UnitTask

func _ready() -> void:
	if not task:
		return
	
	task.finished.connect(_on_task_finished)
	
	_update()

func _on_task_finished() -> void:
	queue_free()

func _update() -> void:
	if is_instance_valid(task):
		icon.texture = task.get_icon()
		_apply_size.call_deferred()

func _apply_size() -> void:
	if is_inside_tree():
		if get_index() == 0:
			custom_minimum_size = Vector2(64, 64)
		else:
			custom_minimum_size = Vector2(42, 42)
		size = custom_minimum_size
