extends HBoxContainer

@export var player_ui: Control
@export var effect_icon: PackedScene

@onready var player = player_ui.get("player") as PlayerCamera
var _current_unit: Unit

func _ready() -> void:
	if not is_instance_valid(player):
		return
	player.main_unit_changed.connect(_on_main_unit_changed)
	_on_main_unit_changed()

func _on_main_unit_changed() -> void:

	if _current_unit:
		var old_effects = _current_unit.unit_effects
		if old_effects.effect_added.is_connected(add_effect):
			old_effects.effect_added.disconnect(add_effect)
	
	_current_unit = player.main_unit
	
	if is_instance_valid(_current_unit):
		_current_unit.unit_effects.effect_added.connect(add_effect)
	
	_update()

func _update() -> void:
	_clear()
	if not is_instance_valid(_current_unit):
		return
	
	for effect in _current_unit.unit_effects.active_effects:
		add_effect(effect)

func _clear() -> void:
	for c in get_children():
		c.queue_free()

func add_effect(effect: Effect) -> void:
	if not effect_icon: return
	
	var inst = effect_icon.instantiate()
	add_child(inst)
	if inst.has_method("set_effect"):
		inst.set_effect(effect)
	else:
		inst.set("effect", effect)
