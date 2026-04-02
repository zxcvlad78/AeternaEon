@tool
class_name MeshCastRange extends MeshInstance3D

const SHADER = preload("res://resources/shaders/spell_cast_range.gdshader")

@export var unit:Unit

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		if not unit:
			return
		
		SD_ECS.append_to(unit, self)
	
	
	if not mesh:
		mesh = PlaneMesh.new()
	
	if not material_override:
		material_override = ShaderMaterial.new()
		material_override.shader = SHADER

func show_range(spell:Spell, _show:bool = true) -> void:
	var cast_range = spell.res.get_cast_range()
	if mesh is PlaneMesh:
		mesh.size.x = cast_range * 2
		mesh.size.y = cast_range * 2
	
	if _show:
		show()
