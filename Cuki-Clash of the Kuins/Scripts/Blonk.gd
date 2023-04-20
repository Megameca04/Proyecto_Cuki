extends CharacterBody2D

enum BlonkState { Patrol, Attacking, Resting }
var Cuki = null
var state = BlonkState.Patrol
var movement = Vector2()
const ATTACK = preload("res://Entidades/Explosion.tscn")
@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var pause_attack_timer = $Pause_attack_timer
@export var blonkSpeed = 50
@export var attackSpeed = 20

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()


func _process(delta):
	animations()

func _physics_process(delta):
	blonkMovement()

func blonkMovement():
	movement = Vector2.ZERO
	if Cuki != null && state == BlonkState.Patrol:
		movement = position.direction_to(Cuki.position)
	else:
		movement = Vector2.ZERO
	set_velocity(movement * blonkSpeed)
	move_and_slide()
	movement = velocity

func animations():
	if movement.x <= 1: #dirección a la que mira
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1
	elif movement.x >= -1:
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1

func defeat():
	self.queue_free()

func _on_vision_field_body_entered(body):
	if body != self:
		if body.get_name() == "Cuki":
			Cuki = body

func _on_vision_field_body_exited(body):
	if body.get_name() == "Cuki":
		Cuki = null

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		health_bar.show()
		hide_timer.start()
		health.current -= 1
	if area.is_in_group("expl_attack"):
		health_bar.show() #mostrar salud
		hide_timer.start() #cuando se desactiva la salud
		health.current -= 2

func _on_attack_area_body_entered(body):
	if body.get_name() == "Cuki":
		var atk = ATTACK.instantiate()
		atk.add_to_group("expl_blonk")
		atk.global_position = self.global_position
		call_deferred("add_sibling",atk)
