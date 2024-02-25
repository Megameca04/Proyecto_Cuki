extends CharacterBody2D

const ATTACK_ZONE = preload("res://Entidades/Enemigos/Proyectiles Chooty/ZonaAtaquePiedra.tscn")
const ELEMENT = 6

var objective_position = Vector2.ZERO
var movement = Vector2.ZERO
var speed = 200

@onready var aliveTimer = $AliveTimer

func _ready():
	aliveTimer.start()
	movement = global_position.direction_to(objective_position)

func _physics_process(_delta):
	
	if speed > 0:
		speed -= abs(pow(aliveTimer.time_left/2,3/2))
	
	set_velocity(movement*speed)
	
	move_and_slide()
	
	if is_on_wall():
		create_attack_zone()
	

func create_attack_zone():
	var az = ATTACK_ZONE.instantiate()
	az.element = ELEMENT
	az.global_position = self.global_position
	call_deferred("add_sibling", az)
	self.queue_free()

func _on_alive_timer_timeout():
	if (ELEMENT != null):
		self.queue_free()
		create_attack_zone()

