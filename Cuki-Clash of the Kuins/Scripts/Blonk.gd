extends CharacterBody2D

var Cuki = null
var movement = Vector2()
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
	if Cuki != null:
		movement = position.direction_to(Cuki.position)
	else:
		movement = Vector2.ZERO
	set_velocity(movement * blonkSpeed)
	move_and_slide()
	movement = velocity

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

func animations():
	if movement.x <= 1: #dirección a la que mira
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1
	elif movement.x >= -1:
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1
