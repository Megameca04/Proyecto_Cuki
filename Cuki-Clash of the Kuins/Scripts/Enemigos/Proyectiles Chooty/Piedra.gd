extends CharacterBody2D

const zonas_daño = {
		0 : "res://Entidades/Enemigos/Proyectiles Chooty/ZonaAtaquePiedra.tscn",
		1 : "res://Entidades/Elementos combates/Explosion.tscn"
}

var objective_position = Vector2.ZERO
var movement = Vector2.ZERO
var in_distance = 0
var Cuki = null
var speed = 200
var element : int = 0
var ZonaAtaque

@onready var aliveTimer = $AliveTimer

func _ready():
	
	if element != 2:
		movement = global_position.direction_to(objective_position)
	else:
		aliveTimer.start()
		
		if Cuki != null:
			movement = global_position.direction_to(Cuki.global_position)
			speed *= 0.75
	
	in_distance = global_position.distance_to(objective_position)
	
	set_velocity(movement*speed)
	
	if element != 3:
		ZonaAtaque = preload(zonas_daño[0])
	else:
		ZonaAtaque = preload(zonas_daño[1])

func _physics_process(_delta):
	move_and_slide()
	
	if element == 2:
		if Cuki != null:
			movement = global_position.direction_to(Cuki.global_position)
			set_velocity(movement*speed)
			if global_position.distance_to(Cuki.global_position) <= 2:
				$S_wait_time.start()
				set_physics_process(false)
	
	if global_position.distance_to(objective_position) <= 2:
		if element == 3:
			blow_up()
		else:
			create_attack_zone()

	if is_on_wall():
		if element == 3:
			blow_up()
		else:
			create_attack_zone()
	

func _process(_delta):
	if (element != 2):
		anim_y()

func anim_y():
	var percent = (in_distance - global_position.distance_to(objective_position))/in_distance
	
	$Sprite2D.position.y = -100*(percent) + 100*pow(percent,2)
	#print("SP: "+str($Sprite2D.global_position)+"/GP: "+str(global_position))

func create_attack_zone():
	var az = ZonaAtaque.instantiate()
	az.element = element
	az.global_position = self.global_position
	call_deferred("add_sibling", az)
	self.queue_free()

func blow_up():
	var expl = ZonaAtaque.instantiate()
	expl.element = element
	expl.add_to_group("expl_attack")
	expl.global_position = self.global_position
	call_deferred("add_sibling",expl)
	self.queue_free()

func _on_alive_timer_timeout():
	if element != null:
		if element == 2:
			self.queue_free()
			create_attack_zone()
		

func _on_s_wait_time_timeout():
	create_attack_zone()
