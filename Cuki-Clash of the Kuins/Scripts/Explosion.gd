extends Area2D

const ELEMENTEFFECT = preload("res://Objetos/Element.tscn")
var ele = null
@onready var sprite = $Sprite2D

func element_appear(effName):
	ele = ELEMENTEFFECT.instantiate()
	ele.name = effName
	ele.set_element_name(effName)
	ele.add_to_group("elements")
	ele.add_to_group(effName)
	ele.global_position = self.global_position
	call_deferred("add_sibling", ele)

func get_element():
	return ele.get_element_name()

func _ready():
	color_changer(ele.name)

func _on_animation_player_animation_finished(_anim_name):
	if (ele != null):
		ele.queue_free()
	queue_free()
	
func color_changer(effName):
	if (effName == "Flame"):
		sprite.modulate = Color(1, 0, 0)
	elif (effName == "Water"):
		sprite.modulate = Color(0, 0, 1)
	elif (effName == "Poison"):
		sprite.modulate = Color (0, 1, 0)
	elif (effName == "Freeze"):
		sprite.modulate = Color(0.5, 0.7, 0)
	elif (effName == "Tar"):
		sprite.modulate = Color(0.5, 0, 0.5)
	elif (effName == "Shock"):
		sprite.modulate = Color(0.8, 0.8, 0.8)
	else:
		sprite.modulate = Color(1, 1, 1)
