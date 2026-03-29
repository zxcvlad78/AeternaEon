extends Control

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

var effect: Effect:
	set(val):
		effect = val
		_update_ui()

func _ready() -> void:
	_update_ui()

func _update_ui() -> void:
	if not is_node_ready() or not effect:
		return
	
	var effect_icon: Texture = effect.res.icon if effect.res.icon else effect.spell.res.icon
	if icon:
		icon.texture = effect_icon
	
	if not effect.finished.is_connected(queue_free):
		effect.finished.connect(queue_free)

func _process(delta: float) -> void:
	label.text = str( snappedf(effect.time_left, 0.1) )
