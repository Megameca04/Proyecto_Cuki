extends CharacterBody2D

const SPEED = 300

var still:bool = true

var movement:Vector2 = Vector2.ZERO

const EXPL = preload("res://Entidades/Explosion.tscn")

func _ready():
	add_to_group("Barrels")

func _physics_process(delta):
	
	if !still:
		set_velocity(movement*SPEED)
		move_and_slide()
		

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		still = false
		$AnimationPlayer.play("Rodar")
		movement = -Vector2(cos(get_angle_to(area.global_position)),sin(get_angle_to(area.global_position)))
	if area.is_in_group("expl_attack"):
		blow_up()

func _on_hitbox_body_entered(body):
	if !still:
		blow_up()

func blow_up():
	var expl = EXPL.instantiate()
	expl.add_to_group("expl_attack")
	expl.global_position = self.global_position
	call_deferred("add_sibling",expl)
	queue_free()
	
