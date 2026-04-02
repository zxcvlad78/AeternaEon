extends Control

@onready var icon: TextureRect = $Icon
@onready var progress_bar: TextureProgressBar = $TextureProgressBar

const BUFF_COLOR = Color(0.5, 1.0, 0.0)
const DEBUFF_COLOR = Color(1.0, 0.0, 0.0, 1.0)

var effect: Effect:
	set(val):
		effect = val
		if effect:
			set_process(!effect.res.is_permanent())
			
			if effect.res.is_debuff:
				progress_bar.tint_progress = DEBUFF_COLOR
			else:
				progress_bar.tint_progress = BUFF_COLOR
			
			progress_bar.max_value = effect.res.get_duration()
			progress_bar.value = effect.time_left
		
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

func _process(_delta: float) -> void:
	progress_bar.value = effect.time_left
