extends CharacterBody2D

var objective_position = Vector2.ZERO
var movement = Vector2.ZERO
var in_distance = 0

const AZ = preload("res://Entidades/Piedra_a_z.tscn")
const EXPL = preload("res://Entidades/Explosion.tscn")
var Cuki = null
var element = ""

@onready var aliveTimer = $AliveTimer

var speed = 200

func _ready():
	print(objective_position)
	if (element != "Shock"):
		movement = global_position.direction_to(objective_position)
	else:
		aliveTimer.start()
		if (Cuki != null):
			movement = global_position.direction_to(Cuki.global_position)
			speed *= 0.75
	
	in_distance = global_position.distance_to(objective_position)
	
	set_velocity(movement*speed)

func _physics_process(_delta):
	move_and_slide()
	
	if (element == "Shock"):
		if (Cuki != null):
			movement = global_position.direction_to(Cuki.global_position)
			set_velocity(movement*speed)
			if global_position.distance_to(Cuki.global_position) <= 2:
				$S_wait_time.start()
				set_physics_process(false)
	
	if global_position.distance_to(objective_position) <= 2:
		if element == "Water":
			blow_up()
		else:
			create_attack_zone(element)

	if is_on_wall():
		if element == "Water":
			blow_up()
		else:
			create_attack_zone(element)
	

func _process(_delta):
	# && ele.get_element_name() != "Tar"
	if (element != "Shock"):
		anim_y()

func anim_y():
	var percent = (in_distance - global_position.distance_to(objective_position))/in_distance
	
	$Sprite2D.position.y = -100*(percent) + 100*pow(percent,2)

func create_attack_zone(effName):
	var az = AZ.instantiate()
	az.element = effName
	az.global_position = self.global_position
	call_deferred("add_sibling", az)
	self.queue_free()

func blow_up():
	var expl = EXPL.instantiate()
	expl.element = element
	expl.add_to_group("expl_attack")
	expl.global_position = self.global_position
	call_deferred("add_sibling",expl)
	self.queue_free()

func _on_alive_timer_timeout():
	if (element != null):
		if (element == "Shock"):
			self.queue_free()
			create_attack_zone("Shock")

func _on_s_wait_time_timeout():
	create_attack_zone(element)
