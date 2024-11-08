extends CharacterBody2D

const SPEED = 300
const EXPL = preload("res://Entidades/Elementos combates/Explosion.tscn")

enum Elements {
	NONE,			#0
	FIRE,			#1
	SHOCK,			#2
	WATER,			#3
	ICE, 			#4
	POISON, 		#5
	TAR				#6
}

@export var element : Elements

var still:bool = true
var movement:Vector2 = Vector2.ZERO

@onready var generAyudas = $GenerAyudas

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
	expl.element = element
	expl.global_position = self.global_position
	if element == Elements.SHOCK:
		generAyudas.generar_solo_bateria(self)
	call_deferred("add_sibling",expl)
	queue_free()
	
