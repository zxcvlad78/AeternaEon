class_name R_WorldObject extends R_BaseObject

@export var _icon:Texture : get = get_icon
func get_icon() -> Texture:
	return _icon

@export var viewmodel:R_ViewModel = R_ViewModel.new()
