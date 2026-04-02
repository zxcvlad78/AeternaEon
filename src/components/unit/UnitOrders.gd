class_name UnitOrders extends Node

signal queue_added(task:UnitTask)
signal queue_removed(task:UnitTask)

@export var unit:Unit

var _queue:Array[UnitTask] = []
var current_task:UnitTask = null

func _ready() -> void:
	SD_ECS.append_to(unit, self)
	
	SimusNetVars.register(
		self,
		["current_task"],
		SimusNetVarConfig.new().flag_mode_server_only().flag_replication().flag_serialization()
	)
	
	SimusNetRPC.register(
		[
			_server_hold_position,
			_server_issue_task,
			_server_interrupt_current,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	SimusNetRPC.register(
		[
			_local_queue_append,
			_local_queue_remove,
			_local_queue_pop_front,
			_local_queue_clear,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)

func queue_append(_task:UnitTask) -> void:
	_local_queue_append(_task)
	SimusNetRPC.invoke(_local_queue_append, _task)

func _local_queue_append(_task:UnitTask) -> void:
	_queue.append(_task)
	queue_added.emit(_task)

func queue_remove(_task:UnitTask) -> void:
	_local_queue_remove(_task)
	SimusNetRPC.invoke(_local_queue_remove, _task)

func _local_queue_remove(_task:UnitTask) -> void:
	if _queue.has(_task):
		_queue.erase(_task)
		queue_removed.emit(_task)

func _local_queue_pop_front() -> void:
	if not _queue.is_empty():
		var task = _queue.pop_front()
		queue_removed.emit(task)

func queue_pop_front() -> void:
	_local_queue_pop_front()
	SimusNetRPC.invoke(_local_queue_pop_front)

func queue_clear() -> void:
	_local_queue_clear()
	SimusNetRPC.invoke(_local_queue_clear)

func _local_queue_clear() -> void:
	var tasks_to_notify = _queue.duplicate()
	
	_queue.clear()
	
	for task in tasks_to_notify:
		queue_removed.emit(task)


func issue_task(task:UnitTask, shift:bool = Input.is_action_pressed("shift")) -> void:
	if multiplayer.is_server():
		_server_issue_task(task, shift)
	else:
		SimusNetRPC.invoke_on_server(_server_issue_task, task, shift)
	

func _server_issue_task(task:UnitTask, shift:bool = false) -> void:
	if not shift:
		_server_interrupt_current()
	
	queue_append(task)
	if _queue.size() == 1:
		_execute_next()

func _execute_next() -> void:
	if _queue.is_empty():
		current_task = null
		return
	
	current_task = _queue.front()
	
	if not is_instance_valid(current_task):
		_on_task_finished()
		return

	current_task.finished.connect(_on_task_finished, CONNECT_ONE_SHOT)
	current_task.start()

func _on_task_finished() -> void:
	if multiplayer.is_server():
		if _queue.is_empty():
			return
		
		queue_pop_front()
		
		_execute_next.call_deferred()

func interrupt_current() -> void:
	SimusNetRPC.invoke_on_server(_server_interrupt_current)

func _server_interrupt_current() -> void:
	if current_task:
		
		if current_task.finished.is_connected(_on_task_finished):
			current_task.finished.disconnect(_on_task_finished)
		current_task.cancel()
		current_task = null
	
	queue_clear()

func hold_position() -> void:
	SimusNetRPC.invoke_on_server(_server_hold_position)

func _server_hold_position() -> void:
	unit.ct_movement.stop()
	unit.spell_machine.interrupt_cast()
	
	interrupt_current()
