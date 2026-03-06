class_name HealthComponent extends Node

signal died

signal health_points_changed
signal max_health_points_changed

@export var target:Node3D

@export var health_points:float = 100.0 : set = set_health_points ##Current health
@export var max_health_points:float = 100.0 : set = set_max_health_points ##Max health

@export_category("Settings")
@export var free_on_death:bool = false

func _ready() -> void:
	if not target:
		target = get_parent()

func set_health_points(value:float) -> void:
	health_points = value
	health_points_changed.emit()
	
	if health_points == 0.0:
		if free_on_death: target.queue_free()
		died.emit()

func set_max_health_points(value:float) -> void:
	max_health_points = value
	max_health_points_changed.emit()

func apply_damage(points:float) -> void: #1300, 500
	if points > health_points:
		health_points -= health_points
	else:
		health_points -= points

func apply_health(points:float) -> void:
	if health_points < max_health_points:
		health_points += points
	else:
		health_points = max_health_points



func apply_full_regen() -> void:
	health_points = max_health_points
