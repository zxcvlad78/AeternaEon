extends HBoxContainer

@export var player_ui: Control
@export var task_icon: PackedScene

@onready var player = player_ui.get("player") as PlayerCamera
var _current_unit: Unit

func _ready() -> void:
	if not is_instance_valid(player):
		return
	player.main_unit_changed.connect(_on_main_unit_changed)
	_on_main_unit_changed()

func _on_main_unit_changed() -> void:
	if player.main_unit == _current_unit:
		return
	
	_current_unit = player.main_unit
	
	if not is_instance_valid(_current_unit):
		return
	
	if not player.main_unit.unit_orders.queue_added.is_connected(_on_queue_added):
		player.main_unit.unit_orders.queue_added.connect(_on_queue_added)
	
	if not player.main_unit.unit_orders.queue_removed.is_connected(_update_children):
		player.main_unit.unit_orders.queue_added.connect(_update_children)

func _on_queue_added(queue_task:UnitTask) -> void:
	add_task(queue_task)
	_update_children()

func _clear() -> void:
	for c in get_children():
		c.queue_free()

func _update(need_clear:bool = true) -> void:
	if need_clear:
		_clear()
	
	for task in player.main_unit.unit_orders._queue:
		add_task(task)
	
	_update_children()

func add_task(task:UnitTask) -> void:
	var new_task_icon = task_icon.instantiate()
	
	new_task_icon.set("task", task)
	add_child(new_task_icon)

func _update_children(exceptions:Array[Node] = []) -> void:
	for c in get_children():
		if exceptions.has(c):
			continue
		
		c.call("_update")
