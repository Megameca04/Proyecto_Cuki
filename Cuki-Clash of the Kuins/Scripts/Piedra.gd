extends CharacterBody2D

var objective_position = Vector2.ZERO
var movement = Vector2.ZERO
var in_distance = 0

const ELEMENTEFFECT = preload("res://Objetos/Element.tscn")
var ele = null

var speed = 200

func _ready():
	movement = global_position.direction_to(objective_position)
	
	in_distance = global_position.distance_to(objective_position)
	
	set_velocity(movement*speed)

func _physics_process(delta):
	move_and_slide()
	
	if global_position.distance_to(objective_position) <= 2:
		self.queue_free()
	if is_on_wall():
		self.queue_free()
	

func _process(delta):
	anim_y()

func anim_y():
	var percent = (in_distance - global_position.distance_to(objective_position))/in_distance
	
	$Sprite2D.position.y = -100*(percent) + 100*pow(percent,2)
	if percent > 0.9:
		$Area2D/CollisionShape2D.disabled = false
