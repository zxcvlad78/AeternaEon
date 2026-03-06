class_name SpellIcon extends Control

@export var resource:R_Spell

@onready var icon:TextureRect = get_node("icon")
@onready var cooldown:ColorRect = get_node("cooldown")
@onready var cooldown_label:Label = cooldown.get_node("label")
@onready var cast_progress:ProgressBar = get_node("cast_progress")
@onready var level:ColorRect = get_node("level")
@onready var level_label:Label = level.get_node("Label")

var cast_timer:Timer = Timer.new()
var spell:Spell

func _ready() -> void:
	_update()
	add_child(cast_timer)
	if is_instance_valid(spell):
		spell.precast_start.connect(on_precast_start)
		spell.casted.connect(on_casted)
	

func _update() -> void:
	if resource:
		icon.texture = resource._icon
	if is_instance_valid(spell):
		level_label.text = "%s/%s" % [str(spell.spell_level), str(spell.resource.max_level)]

func on_precast_start(_by:BaseUnit) -> void:
	cast_progress.value = 0.0
	cast_progress.max_value = spell.resource.precast_time

	cast_timer.wait_time = spell.resource.precast_time
	cast_timer.one_shot = true
	cast_timer.start()

func on_casted(_by:BaseUnit):
	cast_progress.value = 0.0

func _on_timer_timeout() -> void:
	cooldown.hide()

func _process(delta: float) -> void:
	if is_instance_valid(spell):
		if spell.spell_container.is_casting():
			cast_progress.value = cast_timer.wait_time - cast_timer.time_left
		else:
			cast_progress.value = 0.0
		
		cooldown.visible = spell.is_cooldown()
		if spell.is_cooldown():
			
			cooldown_label.text = str(snapped(spell.cooldown, 0.1))
