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
var fill:StyleBoxFlat

@onready var label: Label = $Label
@onready var tail_rect: ProgressBar = $tail_rect

var tween:Tween

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
	
	if not point_counter.points_changed.is_connected(_animate_white_rect):
		point_counter.points_changed.connect(_animate_white_rect)
	
	if not point_counter.points_changed.is_connected(_update):
		point_counter.points_changed.connect(_update)
	if not point_counter.max_points_changed.is_connected(_update):
		point_counter.max_points_changed.connect(_update)
	
	_update()
	_animate_white_rect()

func _animate_white_rect() -> void:
	if not tail_rect:
		return
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(
		tail_rect,
		"value",
		point_counter.points,
		0.5,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _update() -> void:
	if not point_counter:
		return
	
	
	max_value = point_counter.max_points
	value = point_counter.points
	
	tail_rect.max_value = max_value
	
	if label:
		label.text = str(int(value))
