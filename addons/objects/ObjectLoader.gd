class_name ObjectLoader extends Node

signal loading_finished()


@export var directories:PackedStringArray = PackedStringArray([""])
var loaded:Array[R_BaseObject]

var _queue:Array[String] = []
var _is_loading:bool = false

func _ready() -> void:
	scan_to_queue()

func scan_to_queue() -> void:
	for dir in directories:
		_fill_queue(dir)
	
	if _queue.size() > 0:
		_is_loading = true
		for path in _queue:
			ResourceLoader.load_threaded_request(path)

func _fill_queue(path:String) -> void:
	var dir = DirAccess.open(path)
	if not dir: return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path.path_join(file_name)
		if dir.current_is_dir():
			_fill_queue(full_path)
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			_queue.append(full_path)
		file_name = dir.get_next()

func _process(_delta:float) -> void:
	if not _is_loading: return

	var pending_removal = []
	
	for path in _queue:
		var status = ResourceLoader.load_threaded_get_status(path)
		
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var res = ResourceLoader.load_threaded_get(path)
				if res is R_BaseObject and not loaded.has(res):
					loaded.append(res)
				pending_removal.append(path)
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				pending_removal.append(path)
	
	for path in pending_removal:
		_queue.erase(path)

	if _queue.is_empty():
		_is_loading = false
		loading_finished.emit()
		print("Loaded Objects: %s" % R_BaseObject.get_ref_list())
		set_process(false)
