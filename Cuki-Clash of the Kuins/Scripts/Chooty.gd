extends CharacterBody2D

enum ChootyState {Patrol, Running, Shooting, Resting}

var Cuki = null

var Cuki_on_shoot_range = false
var state = ChootyState.Patrol

@onready var shoot_timer = $Shoot_timer
@onready var vision_raycast = $Vision_Raycast
@onready var vision_raycast_2 = $Vision_Raycast_2

@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer

var speed = 200
var movement = Vector2.ZERO
var knockback = Vector2.ZERO

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(delta):
	chootyBehaviour()

func _physics_process(delta):
	chootyMovement()
	print(state)

func chootyMovement():
	movement = Vector2.ZERO
	if Cuki != null && state == ChootyState.Running:
		movement = -position.direction_to(Cuki.position)
		vision_raycast.target_position = movement * 100
		if vision_raycast.is_colliding():
			vision_raycast_2.target_position = movement.orthogonal() * 100
			if vision_raycast_2.is_colliding():
				movement += movement.orthogonal()
			else:
				movement -= movement.orthogonal()
	else:
		movement = Vector2.ZERO
	
	set_velocity(movement * speed)
	move_and_slide()
	movement = velocity

func chootyBehaviour():
	if Cuki != null:
		if distance_from_Cuki() > 100 :
			stateAndAnimationChange(ChootyState.Shooting)
		else:
			stateAndAnimationChange(ChootyState.Running)
	else:
		stateAndAnimationChange(ChootyState.Patrol)

func stateAndAnimationChange(chootyState):
	state = chootyState
	
	match chootyState:
		ChootyState.Patrol:
			$AnimationPlayer.play("Default")
		ChootyState.Running:
			$AnimationPlayer.play("Default")
		ChootyState.Shooting:
			$AnimationPlayer.play("Shoot")
		ChootyState.Resting:
			$AnimationPlayer.play("Default")

func distance_from_Cuki():
	if Cuki != null:
		var distance = sqrt(pow(Cuki.global_position.x - global_position.x,2)+pow(Cuki.global_position.y - global_position.y,2))
		return distance

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki":
			Cuki = body

func _on_vision_field_body_exited(body):
	if body.get_name() == "Cuki":
		Cuki = null
