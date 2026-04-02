extends TextureRect

@export var player_ui:Control
@onready var player = player_ui.get("player") as PlayerCamera

@onready var sub_viewport: SubViewport = $SubViewport

var _current_unit:Unit

func _ready() -> void:
	if not is_instance_valid(player):
		return
	player.main_unit_changed.connect(_on_main_unit_changed)
	_on_main_unit_changed()

func _clear() -> void:
	for c in sub_viewport.get_children():
		c.queue_free()

func add_portrait() -> void:
	if _current_unit:
		var prefab = _current_unit.resource.portrait.prefab
		if not prefab:
			return
		
		var new_portrait = prefab.instantiate()
		sub_viewport.add_child(new_portrait)


func _on_main_unit_changed() -> void:
	if player.main_unit == _current_unit:
		return
	
	_current_unit = player.main_unit
	
	_clear()
	
	if _current_unit:
		add_portrait()
	
