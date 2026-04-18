class_name CT_Mana extends CT_PointCounter

var replinish_value:R_PointValue
var mana_regen:float = 0.0

func _ready() -> void:
	super()
	
	replinish_value = R_PointValue.new()
	
	if root is Unit:
		root.resource.base_mana_changed.connect(_on_base_mana_changed)
		root.resource.base_intelligence_changed.connect(_on_base_intelligence_changed)
	
	_update()

func _on_base_mana_changed() -> void:
	_update()

func _on_base_intelligence_changed() -> void:
	_update()

func _update() -> void:
	if root is Unit:
		mana_regen = root.resource.get_mana_regen()
		max_points = root.resource.get_max_mana()

func _process(delta: float) -> void:
	if replinish_value:
		replinish_value.points = mana_regen * delta
		apply_replenish(replinish_value)
