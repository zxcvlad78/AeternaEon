class_name PlayerUI extends CanvasLayer

@onready var portrait = get_node("ui/portrait")
@onready var unit_name = get_node("ui/portrait/hero_name")
@onready var portrait_subviewport_container:SubViewportContainer = portrait.get_node("SubViewportContainer")
@onready var portrait_subviewport:SubViewport = portrait_subviewport_container.get_node("SubViewport")

@onready var spell_list_box_container:SpellListBoxContainer = $ui/spell_list/SpellListBoxContainer

static var instance:PlayerUI
var player:Player

func _ready() -> void:
	if is_multiplayer_authority():
		Player.get_local_instance().current_unit_changed.connect(_update)
		instance = self
	
	


func _update(_unit_res:R_UnitProperties=null) -> void:
	unit_name.text = Player.get_local_instance().current_unit.unit_resource._name
	portrait_subviewport_container.visible = is_instance_valid(Player.get_local_instance().current_unit)
