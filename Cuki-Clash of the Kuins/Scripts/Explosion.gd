extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	color_changer(self.name)
	print(self.name)

func _on_animation_player_animation_finished(_anim_name):
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
