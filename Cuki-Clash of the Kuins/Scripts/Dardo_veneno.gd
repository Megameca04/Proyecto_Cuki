extends RayCast2D

var element = "Poison"
var objective = Vector2.ZERO

func _ready():
	target_position = to_local(objective)
	$Line2D.add_point(self.target_position,0)
	$Line2D.add_point(Vector2.ZERO,1)
	$AnimationPlayer.play("Disparar_dardo")


func _on_animation_player_animation_finished(anim_name):
	self.queue_free()


