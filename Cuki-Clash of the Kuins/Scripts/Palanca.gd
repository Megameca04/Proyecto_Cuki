extends StaticBody2D

@export var colorhex:String = ""

var state:
	set(new_state):
		if state == true:
			$AnimationPlayer.play("On")
		else:
			$AnimationPlayer.play("Off")
		state = new_state

func _ready():
	$Color.color = Color(colorhex)

func _process(delta):
	$Estado.visible = !state

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		state = !state
