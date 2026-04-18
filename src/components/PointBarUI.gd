@tool
class_name PointBarUI extends ProgressBar

@export var player_ui: Control

@export var var_name:StringName ##Variable name of the CT_PointCounter. ct_health or ct_mana and etc
@export var progress_color:Color :
	set(val):
		progress_color = val
		
		self_modulate = progress_color

var point_counter:CT_PointCounter :
	set(val):
		point_counter = val
		
		if not is_instance_valid(point_counter):
			return
		
		if not point_counter.points_changed.is_connected(_update):
			point_counter.points_changed.connect(_update)
		
		if not point_counter.points_changed.is_connected(_update):
			point_counter.max_points_changed.connect(_update)
		
		_update()

@onready var player = player_ui.get("player") as PlayerCamera
var _current_unit: Unit

var value_label:Label

func _ready() -> void:
	if not is_instance_valid(player):
		return
	player.main_unit_changed.connect(_on_main_unit_changed)
	_on_main_unit_changed()
	
	if !value_label:
		value_label = Label.new()
		add_child(value_label)
	
	_update()

func _on_main_unit_changed() -> void:
	if Engine.is_editor_hint():
		return
	
	
	if _current_unit == player.main_unit:
		return
	
	_current_unit = player.main_unit
	 
	if not is_instance_valid(_current_unit):
		return
	
	var point_counter_val = _current_unit.get(var_name)
	if not is_instance_valid(point_counter_val):
		return
	
	if not point_counter_val is CT_PointCounter:
		return
	
	point_counter = point_counter_val
	

func _on_points_update() -> void:
	if is_instance_valid(point_counter):
		value = point_counter.points

func _on_max_points_update() -> void:
	if is_instance_valid(point_counter):
		max_value = point_counter.max_points

func _update() -> void:
	_on_points_update()
	_on_max_points_update()
	
	var format_value_text:String = "%s/%s" % [
		str(int(value)),
		str(int(max_value))
		]
	if value_label:
		value_label.text = format_value_text
	
	
	
