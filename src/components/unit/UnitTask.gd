class_name UnitTask extends RefCounted

signal finished

var unit:Unit
var target:Variant

func _init(_unit:Unit = null, _target:Variant = null):
	SimusNetVars.register(
		self,
		[
			"unit",
			"target",
		]
		
	)
	
	unit = _unit
	target = _target

func start() -> void:
	pass

func cancel() -> void:
	pass

func on_finish() -> void:
	finished.emit()
