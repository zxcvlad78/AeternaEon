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
		if is_inside_tree():
			if get_index() == 0:
				scale = Vector2(1.5, 1.5)
				print(self)
			else:
				scale = Vector2.ONE
