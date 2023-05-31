extends Area2D

const ELEMENTEFFECT = preload("res://Objetos/Element.tscn")
var ele = null

func element_appear(effName):
	ele = ELEMENTEFFECT.instantiate()
	ele.name = effName
	ele.add_to_group("elements")
	ele.global_position = self.global_position
	call_deferred("add_sibling", ele)

func _on_animation_player_animation_finished(_anim_name):
	if (ele != null):
		ele.queue_free()
	queue_free()
