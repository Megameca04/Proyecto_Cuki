extends CharacterBody2D

var objective_position = Vector2.ZERO
var movement = Vector2.ZERO
var in_distance = 0

const ELEMENTEFFECT = preload("res://Objetos/Element.tscn")
const EXPL = preload("res://Entidades/Explosion.tscn")
var ele = null
var Cuki = null
var reachedObjective = false
@onready var aliveTimer = $AliveTimer

var speed = 200

func _ready():
	if (ele.get_element_name() != "Shock"):
		movement = global_position.direction_to(objective_position)
	else:
		aliveTimer.start()
		if (Cuki != null):
			movement = global_position.direction_to(Cuki.global_position)
	
	in_distance = global_position.distance_to(objective_position)
	
	if (ele.get_element_name() == "Tar"):
		set_velocity(movement*(speed/2))
	else:
		set_velocity(movement*speed)

func _physics_process(delta):
	if (!reachedObjective):
		move_and_slide()
	if (ele != null):
		ele.position = self.position
		if (ele.get_element_name() == "Shock"):
			if (Cuki != null):
				movement = global_position.direction_to(Cuki.global_position)
				set_velocity(movement*speed)
				if global_position.distance_to(Cuki.global_position) <= 2:
					ele.queue_free()
					self.queue_free()
	
	if global_position.distance_to(objective_position) <= 2:
		if (ele != null):
			if (ele.get_element_name() != "Tar"):
				ele.queue_free()
				self.queue_free()
			else:
				if (!reachedObjective):
					reachedObjective = true
					aliveTimer.start()
	if is_on_wall():
		if (ele != null):
			if (ele.get_element_name() == "Tar"):
				blow_up()
			ele.queue_free()
		self.queue_free()
	

func _process(delta):
	if (ele.get_element_name() != "Shock"):
		anim_y()

func anim_y():
	var percent = (in_distance - global_position.distance_to(objective_position))/in_distance
	
	$Sprite2D.position.y = -100*(percent) + 100*pow(percent,2)
	if percent > 0.9:
		$Area2D/CollisionShape2D.disabled = false

func createElementalEffect(effName):
	ele = ELEMENTEFFECT.instantiate()
	if (effName != ""):
		ele.name = effName
		ele.set_element_name(effName)
	ele.add_to_group("Piedra")
	ele.global_position = self.global_position
	call_deferred("add_sibling", ele)

func blow_up():
	var expl = EXPL.instantiate()
	expl.name = ele.get_element_name()
	expl.add_to_group("expl_attack")
	expl.global_position = self.global_position
	call_deferred("add_sibling",expl)
	expl.element_appear(ele.get_element_name())
	ele.queue_free()
	self.queue_free()


func _on_area_2d_body_entered(body):
	if (ele != null):
		if (ele.name == "Shock"):
			if (body.name == "Cuki"):
				Cuki = body


func _on_alive_timer_timeout():
	if (ele != null):
		if (ele.get_element_name() == "Shock"):
			ele.queue_free()
			self.queue_free()
		if (ele.get_element_name() == "Tar"):
			blow_up()
			
