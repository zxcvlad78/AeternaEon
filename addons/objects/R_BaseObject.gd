@abstract
class_name R_BaseObject extends Resource

static var _ref_list:Array[R_BaseObject] = [] : get = get_ref_list
static func get_ref_list() -> Array[R_BaseObject]:
	return _ref_list

func _init() -> void:
	if !_ref_list.has(self):
		_ref_list.append(self)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _ref_list.has(self):
			_ref_list.erase(self)
