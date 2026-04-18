@tool
extends Control

@export var active_ablity_border:Dictionary[StringName, Texture] = {"normal": null, "down": null}
@export var passive_ablity_border:Dictionary[StringName, Texture] = {"normal": null, "down": null}

@onready var icon: TextureRect = $Icon
@onready var button: Button = $Button

@onready var rect_well: TextureRect = $Well
@onready var rect_inner: TextureRect = $Inner
@onready var rect_ability_type: TextureRect = $AbilityType

var spell:Spell

func _ready() -> void:
	_update()
	
	button.pressed.connect(_on_button_pressed)
	
	rect_ability_type.texture = get_type_texture()

	if spell:
		if spell.res.ability_type == R_Spell.AbilityType.ACTIVE:
			var label = rect_ability_type.get_node_or_null("HotKey")
			if label:
				var events = InputMap.action_get_events("cast_spell_%s" % spell.get_index())
				if not events.is_empty():
					label.text = events[0].as_text().split(" ")[0]
					label.show()
	


func _update() -> void:
	if not is_instance_valid(spell):
		return
	
	
	if spell.res:
		icon.texture = spell.res.icon

func get_type_texture(state: StringName = "normal") -> Texture:
	if not spell or not spell.res:
		return null
	
	var dict = active_ablity_border if spell.res.ability_type == R_Spell.AbilityType.ACTIVE else passive_ablity_border
	return dict.get(state)

func _input(event: InputEvent) -> void:
	if not is_instance_valid(spell): return
	
	var action_name = "cast_spell_%s" % spell.get_index()
	
	if event.is_action(action_name):
		if event.is_pressed():
			rect_ability_type.texture = get_type_texture("down")
		else:
			rect_ability_type.texture = get_type_texture("normal")

func _on_button_pressed() -> void:
	if is_instance_valid(spell):
		spell.spell_machine._requeset_try_precast(spell.get_index())
		_update()
