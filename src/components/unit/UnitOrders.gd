class_name UnitOrders extends Node

@export var unit:Unit

var _queue:Array[UnitTask] = []
var current_task:UnitTask = null

func _ready() -> void:
	SD_ECS.append_to(unit, self)
	
	SimusNetRPC.register(
		[
			_server_hold_position,
			_server_issue_task,
			_server_interrupt_current,
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	#SimusNetVars.register(
		#self,
		#[
			#"_queue",
			#"current_task"
		#],
		#SimusNetVarConfig.new().flag_serialization().flag_replication()
	#)

func issue_task(task:UnitTask, shift:bool = Input.is_action_pressed("shift")) -> void:
	SimusNetRPC.invoke_on_server(_server_issue_task, task, shift)

func _server_issue_task(task:UnitTask, shift:bool = false) -> void:
	if not shift:
		interrupt_current()
		_queue.clear()
	
	_queue.append(task)
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
	if _queue.is_empty():
		return
	
	_queue.pop_front()
	
	_execute_next.call_deferred()

func interrupt_current() -> void:
	SimusNetRPC.invoke_on_server(_server_interrupt_current)

func _server_interrupt_current() -> void:
	if current_task:
		
		if current_task.finished.is_connected(_on_task_finished):
			current_task.finished.disconnect(_on_task_finished)
		current_task.cancel()
		current_task = null
	
	_queue.clear() 

func hold_position() -> void:
	SimusNetRPC.invoke_on_server(_server_hold_position)

func _server_hold_position() -> void:
	unit.ct_movement.stop()
	unit.spell_machine.interrupt_cast()
	
	interrupt_current()
