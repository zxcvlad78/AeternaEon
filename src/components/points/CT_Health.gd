@tool
class_name CT_Health extends CT_PointCounter

var replinish_value:R_PointValue
var health_regen:float = 0.0

func _init() -> void:
	var enabled:bool = Engine.is_editor_hint()
	
	set_process(enabled)

func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		return
	
	replinish_value = R_PointValue.new()
	
	if root is Unit:
		root.resource.base_health_changed.connect(_on_base_health_changed)
		root.resource.base_strength_changed.connect(_on_base_strength_changed)
	
	_update()

func _on_base_health_changed() -> void:
	_update()

func _on_base_strength_changed() -> void:
	_update()

func _update() -> void:
	if Engine.is_editor_hint():
		return
	
	if root is Unit:
		health_regen = root.resource.get_health_regen()
		max_points = root.resource.get_max_health()

func _process(delta: float) -> void:
	if replinish_value:
		replinish_value.points = health_regen * delta
		apply_replenish(replinish_value)
