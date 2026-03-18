extends Control

@onready var btn_container = %BtnContainer
@onready var popups = %Popups

func _ready() -> void:
	for child in btn_container.get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child))

func _switch_popup(name:String, hide_all:bool = true) -> void:
	var popup = popups.find_child(name, false)
	popup.show()
	
	if hide_all:
		for child in popups.get_children():
			if child == popup:
				continue
			
			child.hide()

func _on_button_pressed(btn:Button) -> void:
	if not is_instance_valid(btn):
		return
	
	match btn.name:
		"Host":
			Network.create_server()
			
		"Connect":
			_switch_popup("ServerList")
