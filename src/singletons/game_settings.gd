extends Node

signal debug_mode_changed()

@onready var debug_set_command:SD_ConsoleCommand = SD_ConsoleCommand.get_or_create("debug.enabled")

var debug_enabled:bool = false : set = set_debug
var camera_speed:float = 10.0


func _ready() -> void:
	debug_set_command.executed.connect(set_debug.bind(debug_set_command))

func set_debug(value:bool) -> void:
	print(value)
	debug_enabled = value
