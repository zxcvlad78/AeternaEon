extends HBoxContainer

@export var player_ui: Control
@export var task_icon: PackedScene

@onready var player = player_ui.get("player") as PlayerCamera
var _current_unit: Unit

func _ready() -> void:
	if not is_instance_valid(player): return
	player.main_unit_changed.connect(_on_main_unit_changed)
	_on_main_unit_changed()

func _on_main_unit_changed() -> void:
	if is_instance_valid(_current_unit):
		var orders = _current_unit.unit_orders
		if orders.queue_added.is_connected(_on_queue_added):
			orders.queue_added.disconnect(_on_queue_added)
		if orders.queue_removed.is_connected(_on_queue_removed):
			orders.queue_removed.disconnect(_on_queue_removed)

	_current_unit = player.main_unit
	
	if not is_instance_valid(_current_unit):
		return
	
	_current_unit.unit_orders.queue_added.connect(_on_queue_added)
	_current_unit.unit_orders.queue_removed.connect(_on_queue_removed)
	
	_update_ui()

func _on_queue_added(task: UnitTask) -> void:
	for child in get_children():
		if child.get("task") == task:
			return 
	
	add_task_icon(task)
	_refresh_layout()

func _on_queue_removed(task: UnitTask) -> void:
	for child in get_children():
		if child.get("task") == task:
			child.queue_free()
			break
	_refresh_layout()

func _refresh_layout() -> void:
	_update_visibility.call_deferred()
	
	for child in get_children():
		if child.is_queued_for_deletion(): continue
		
		if child.has_method("_update"):
			child.call_deferred("_update")

func _update_visibility() -> void:
	return
	if !is_instance_valid(_current_unit):
		visible = false
		return
	
	visible = _current_unit.unit_orders._queue.size() > 1

func _clear() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()

func _update_ui() -> void:
	_clear()
	if not is_instance_valid(_current_unit):
		return
	
	for task in _current_unit.unit_orders._queue:
		add_task_icon(task)
	
	_refresh_layout()


func add_task_icon(task:UnitTask) -> void:
	var new_task_icon = task_icon.instantiate()
	new_task_icon.set("task", task)
	add_child(new_task_icon)
