extends CharacterBody2D

const SPEED = 300

var still:bool = true

var movement:Vector2 = Vector2.ZERO

const EXPL = preload("res://Entidades/Explosion.tscn")

func _physics_process(delta):
	
	
	
	if !still:
		set_velocity(movement*SPEED)
		move_and_slide()
		

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		still = false
		$AnimationPlayer.play("Rodar")
		movement = -Vector2(cos(get_angle_to(area.global_position)),sin(get_angle_to(area.global_position)))


func _on_hitbox_body_entered(body):
	if !still:
		var expl = EXPL.instantiate()
		expl.global_position = self.global_position
		call_deferred("add_sibling",expl)
		queue_free()
	
