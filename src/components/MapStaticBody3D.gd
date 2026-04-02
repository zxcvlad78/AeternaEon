class_name MapStaticBody3D extends StaticBody3D

@export var click_visual:PackedScene
@export var goto_visual:Node3D


func show_goto_visual(pos:Vector3) -> void:
	if not goto_visual:
		return
	goto_visual.global_position = pos
	var anim_player:AnimationPlayer = (goto_visual.get_node("AnimationPlayer") as AnimationPlayer)
	if anim_player.is_playing():
		anim_player.seek(0.0)
	anim_player.play("new_animation")

func create_click_visual(pos:Vector3) -> void:
	if not click_visual:
		return
	var inst = click_visual.instantiate()
	get_tree().root.add_child(inst)
	inst.global_position = pos
	
	await get_tree().create_timer(1.0).timeout
	
	inst.queue_free()
