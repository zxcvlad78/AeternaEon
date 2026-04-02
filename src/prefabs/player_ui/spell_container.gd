extends HBoxContainer

@export var player_ui:Control
@onready var player = player_ui.get("player") as PlayerCamera
@export var spell_icon:PackedScene

var _current_unit:Unit

func _ready() -> void:
	if not is_instance_valid(player):
		return
	player.main_unit_changed.connect(_on_main_unit_changed)
	_on_main_unit_changed()

func _on_main_unit_changed() -> void:
	if player.main_unit == _current_unit:
		return
	
	_current_unit = player.main_unit
	
	if _current_unit:
		_update()

func add_spell_icon(spell:Spell, pos:int = -1) -> void:
	var new_spell_icon = spell_icon.instantiate()
	new_spell_icon.set("spell", spell)
	add_child(new_spell_icon)
	
	if pos == -1:
		return
	
	move_child(new_spell_icon, pos)

func remove_spell_icon(spell:Spell) -> void:
	for c in get_children():
		var c_spell:Spell =  c.get("spell")
		if not c_spell:
			continue
		
		if c_spell == spell:
			c.queue_free()

func _clear() -> void:
	for c in get_children():
		c.queue_free()

func _update() -> void:
	_clear()
	
	for spell in _current_unit.spell_machine.spell_instances:
		print(spell)
		add_spell_icon(spell)
