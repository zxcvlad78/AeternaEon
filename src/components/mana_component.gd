class_name ManaComponent extends Node

signal mana_points_changed
signal max_mana_points_changed

@export var target:Node3D

@export var mana_points:float = 100.0 : set = set_mana_points ##Current mana
@export var max_mana_points:float = 100.0 : set = set_max_mana_points ##Max mana

func _ready() -> void:
	if not target:
		target = get_parent()

func set_mana_points(value:float) -> void:
	mana_points = value
	mana_points_changed.emit()

func set_max_mana_points(value:float) -> void:
	max_mana_points = value
	max_mana_points_changed.emit()

func apply_replenish(points:float) -> void: ## пополнить ману
	if mana_points < max_mana_points:
		mana_points += points

func apply_diminish(points:float) -> void: ## уменьшить ману
	mana_points -= points

func apply_full_regen() -> void:
	mana_points = max_mana_points
