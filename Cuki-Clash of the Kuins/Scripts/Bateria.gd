extends StaticBody2D

@export var colorhex:String = ""
var can_be_used = true

var state:
	set(new_state):
		if can_be_used:
			if state == true:
				$AnimationPlayer.play("On")
			else:
				$AnimationPlayer.play("Off")
			state = new_state

func _ready():
	$Color.color = Color(colorhex)

func _process(delta):
	$Estado.visible = !state
	$ProgressBar.value = $Timer.time_left

func _on_hitbox_area_entered(area):
	if area.name == "Shock":
		state = true
		$Timer.start()

func _on_timer_timeout():
	state = false
