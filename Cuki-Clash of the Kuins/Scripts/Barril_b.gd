extends CharacterBody2D

const SPEED = 300

var still:bool = true

var movement:Vector2 = Vector2.ZERO

const EXPL = preload("res://Entidades/Explosion.tscn")

@export var elementName = "None"

func _ready():
	add_to_group("Barrels")

func _physics_process(_delta):
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

func _on_hitbox_body_entered(_body):
	if !still:
		blow_up()

func blow_up():
	var expl = EXPL.instantiate()
	expl.name = elementName
	expl.global_position = self.global_position
	expl.add_to_group(elementName)
	call_deferred("add_sibling",expl)
	queue_free()
	
