class_name SpellListBoxContainer extends HBoxContainer

@export var spell_icon_prefab:PackedScene


func _ready() -> void:
	#if is_instance_valid(Player.instance):
	Player.instance.current_unit_changed.connect(_update)
	_update()

func _clear() -> void:
	for child in get_children():
		child.queue_free()

func _update(_unit_res:R_UnitProperties=null) -> void:
	if is_instance_valid(Player.instance.current_unit):
		_clear()
		var spells:Array[Spell] = Player.instance.current_unit.spell_container.spells
		for spell in spells:
			var new_spell_icon:SpellIcon = spell_icon_prefab.instantiate()
			new_spell_icon.resource = spell.resource
			new_spell_icon.spell = spell
			add_child(new_spell_icon)
