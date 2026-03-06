extends ProgressBar

@export var player_ui:PlayerUI

@export var base_path:String = "health_component" ##from player/current_unit/...
@export var value_variable:String = "health_points" ##from player/current_unit/...
@export var max_value_variable:String = "max_health_points" ##from player/current_unit/...
@onready var label = get_node("Label")

@onready var noise:TextureRect = get_node("noise")

func _update() -> void:
	if not player_ui:
		player_ui = PlayerUI.instance
	
	value = player_ui.player.current_unit.get(base_path).get(value_variable)
	max_value = player_ui.player.current_unit.get(base_path).get(max_value_variable)
	
	var format = "%s/%s" % [snapped(value, 0.1), snapped(max_value, 0.1)]
	label.text = format


func _process(_delta: float) -> void:
	noise.size.x = (size.x * value) / max_value
	if is_instance_valid(player_ui):
		if is_instance_valid(player_ui.player):
			if is_instance_valid(player_ui.player.current_unit):
	
				_update()
