extends RayCast2D

var element = "Poison"
var objective = Vector2.ZERO

func _ready():
	target_position = to_local(objective)

func _process(_delta):
	if $Line2D.get_point_count() < 2:
		$Line2D.add_point(Vector2.ZERO,0)
		if is_colliding():
			$Line2D.add_point(to_local(get_collision_point()),1)
		else:
			$Line2D.add_point(self.target_position,1)
		$AnimationPlayer.play("Disparar_dardo")


func _on_animation_player_animation_finished(anim_name):
	if is_colliding():
		var cuerpo = get_collider()
		if cuerpo.is_in_group("Enemy") or cuerpo.name == "Cuki":
			get_collider().attackedBySomething(0,1,self)
			get_collider().elemental_damage("Poison")
	self.queue_free()


