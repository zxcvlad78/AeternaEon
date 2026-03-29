@tool
class_name MP_CanvasLayer extends CanvasLayer


enum UI_Mode {
	AUTHORITY
}

@export var mode:UI_Mode = UI_Mode.AUTHORITY

@export var ui_prefab:PackedScene :
	set(val):
		ui_prefab = val
		
		if not is_inside_tree():
			return
		_update()

@export_group("Variables")
@export var root_node:Node

##Dictionary {"root_node_var_name": "ui_var_name"}
@export var properties:Dictionary[StringName, StringName]

var ui_inst:Node



func _ready() -> void:
	_update()

func set_variables(ui:Node) -> void:
	if not root_node:
		return
	
	for prop in properties.keys():
		var val 
		if prop == "self":
			val = root_node
		else:
			val = root_node.get(prop)
		if not val:
			continue
		
		
		ui.set(properties.get(prop), val)

func _update() -> void:
	if Engine.is_editor_hint():
		add_ui()
		return
	
	if mode == UI_Mode.AUTHORITY:
		if is_multiplayer_authority():
			add_ui()

func add_ui() -> void:
	if not ui_prefab:
		return
	
	if is_instance_valid(ui_inst):
		ui_inst.queue_free()
	
	ui_inst = ui_prefab.instantiate()
	
	set_variables(ui_inst)
	add_child(ui_inst) 
