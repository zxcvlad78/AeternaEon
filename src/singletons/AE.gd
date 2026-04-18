extends Node

var click_visual_prefab:PackedScene = preload("res://src/prefabs/click_visual.tscn")
var goto_visual_prefab:PackedScene = preload("res://src/prefabs/goto_visual.tscn")

var goto_visual:Node3D

func _ready() -> void:
	goto_visual = goto_visual_prefab.instantiate()
	add_child(goto_visual)

func get_leveled_value(level:int, array:Array, default_value:Variant = null) -> Variant:
	if array.is_empty():
		return default_value
	
	if level > array.size():
		return array.back()
	
	var value = array[level]
	
	return value

func get_leveled_value_dict(level:int, dict:Dictionary, array_name:String, default_value:Variant = null) -> Variant:
	var array = dict.get(array_name)
	
	if not array:
		return default_value
	
	if not array is Array:
		return default_value
	
	
	return get_leveled_value(level, array, default_value)

func get_status_by_id(id:StringName) -> StringName:
	var text:String
	if id == &"stun":
		text = &"Stunned"
	else:
		text = &"Status"
	
	return text


func spawn_unit(resource:R_Unit, root, pos:Vector3) -> void:
	if not root:
		return
	if not resource:
		return
	if not resource.prefab:
		return
	
	var inst = resource.prefab.instantiate()
	inst.set("resource", resource.duplicate())
	root.add_child(inst)
	
	if inst is Node3D:
		inst.global_position = pos


func show_goto_visual(pos:Vector3) -> void:
	if not is_instance_valid(goto_visual):
		return
	
	if not goto_visual.is_inside_tree():
		return
	
	goto_visual.global_position = pos
	var anim_player:AnimationPlayer = (goto_visual.get_node("AnimationPlayer") as AnimationPlayer)
	if anim_player.is_playing():
		anim_player.seek(0.0)
	anim_player.play("new_animation")

func create_click_visual(pos:Vector3) -> void:
	if not click_visual_prefab:
		return
	var inst = click_visual_prefab.instantiate()
	get_tree().root.add_child(inst)
	inst.global_position = pos
	
	await get_tree().create_timer(1.0).timeout
	
	inst.queue_free()
