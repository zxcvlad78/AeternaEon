@tool
class_name PointBar extends ProgressBar

static func get_default_prefab() -> PackedScene:
	return load("res://src/prefabs/point_bar/point_bar.tscn")

@export var color:Color = Color.DARK_RED :
	set(val):
		color = val
		if fill:
			fill.set("bg_color", color)

var point_counter:CT_PointCounter
var fill: StyleBoxFlat

@onready var label: Label = $Label

func _ready() -> void:
	var original_style = get_theme_stylebox("fill", "ProgressBar")
	
	if original_style:
		fill = original_style.duplicate()
		add_theme_stylebox_override("fill", fill)
		fill.set("bg_color", color)
	
	if Engine.is_editor_hint():
		return

	if not point_counter:
		return
	
	if not point_counter.points_changed.is_connected(_update):
		point_counter.points_changed.connect(_update)
	if not point_counter.max_points_changed.is_connected(_update):
		point_counter.max_points_changed.connect(_update)
	
	_update()

func _update() -> void:
	if not point_counter:
		return
	
	
	max_value = point_counter.max_points
	value = point_counter.points
	if label:
		label.text = str(snappedf(value, 0.1))
