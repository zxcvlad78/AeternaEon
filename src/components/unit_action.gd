class_name UnitAction extends Node

signal success
signal interrupted

@export var can_interrupt:bool = true

func interrupt() -> void:
	interrupted.emit()

func can_do() -> bool:
	
	return true

func do() -> void:
	if not can_do():
		return
	
	success.emit()
	queue_free()
