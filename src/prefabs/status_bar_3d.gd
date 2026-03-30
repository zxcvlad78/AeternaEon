extends Node3D

@onready var progress_bar: ProgressBar = $SubViewport/Control/ProgressBar
@onready var label: Label = $SubViewport/Control/Label

@export var unit_effects:UnitEffects

var _current_effect:Effect :
	set(val):
		if val:
			var text:String
			if val.res.statusbar_text:
				text = val.res.statusbar_text
			else:
				text = AE.get_status_by_id(val.res.id)
			
			label.text = text
			progress_bar.max_value = val.res.get_duration()
			progress_bar.value = val.time_left
		
		_current_effect = val

func _ready() -> void:
	if not unit_effects:
		return
	
	unit_effects.effect_added.connect(_effect_added)
	unit_effects.effect_removed.connect(_effect_removed)

func _process(_delta: float) -> void:
	if _current_effect:
		progress_bar.value = _current_effect.time_left

func _effect_added(effect:Effect) -> void:

	if effect.res.statusbar_visible:
		_current_effect = effect
		show()
		

func _effect_removed(effect:Effect) -> void:
	if effect == _current_effect:
		_current_effect = null
		hide()
