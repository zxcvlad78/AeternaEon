class_name UnitEffects extends Node

signal effect_added(effect: Effect)
signal effect_removed(effect: Effect)
signal effects_updated

@export var unit: Unit

var active_effects_map: Dictionary = {}
var active_effects: Array[Effect] = []

func _ready() -> void:
	if not unit:
		return
	
	SD_ECS.append_to(unit, self)

func add_effect(effect: Effect) -> void:
	var effect_id = effect.res.id
	
	if not effect.res.stackable and active_effects_map.has(effect_id):
		var existing = active_effects_map[effect_id][0]
		existing.time_left = effect.res.get_duration()
		return
	
	
	
	if not active_effects_map.has(effect_id):
		active_effects_map[effect_id] = []
	active_effects_map[effect_id].append(effect)
	
	active_effects.append(effect)
	
	effect.time_left = effect.res.get_duration()
	effect.on_start()
	effect_added.emit(effect)
	effects_updated.emit()

func find_effect_by_id(effect_id: StringName) -> Effect:
	if active_effects_map.has(effect_id):
		return active_effects_map[effect_id][0]
	return null

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	var changed = false
	
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		effect.update(delta)
		
		if effect.is_finished:
			_remove_from_internal_storage(effect)
			active_effects.remove_at(i)
			effect_removed.emit(effect)
			changed = true
	
	if changed:
		effects_updated.emit()

func _remove_from_internal_storage(effect: Effect) -> void:
	var effect_id = effect.res.id
	if active_effects_map.has(effect_id):
		active_effects_map[effect_id].erase(effect)
		if active_effects_map[effect_id].is_empty():
			active_effects_map.erase(effect_id)
