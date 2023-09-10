extends CharacterBody2D

var objective_position = Vector2.ZERO
var movement = Vector2.ZERO

const AZ = preload("res://Entidades/Piedra_a_z.tscn")
var element = "Tar"

@onready var aliveTimer = $AliveTimer

var speed = 200

func _ready():
	aliveTimer.start()
	movement = global_position.direction_to(objective_position)

func _physics_process(delta):
	
	if speed > 0:
		speed -= abs(pow(aliveTimer.time_left/2,3/2))
	
	set_velocity(movement*speed)
	
	move_and_slide()
	
	if is_on_wall():
		create_attack_zone(element)
	

func create_attack_zone(effName):
	var az = AZ.instantiate()
	az.element = effName
	az.global_position = self.global_position
	call_deferred("add_sibling", az)
	self.queue_free()

func _on_alive_timer_timeout():
	if (element != null):
		self.queue_free()
		create_attack_zone("Tar")

