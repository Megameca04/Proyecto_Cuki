extends CharacterBody2D

enum ChootyState {Patrol, Running, Shooting, AfterShooting, Resting}

const STONE = preload("res://Entidades/Piedra.tscn")

var Cuki = null

var Cuki_on_shoot_range = false
var state = ChootyState.Patrol
var can_shoot = true

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
	$Label.text = str(state)

func _physics_process(delta):
	chootyMovement()

func chootyMovement():
	movement = Vector2.ZERO
	if Cuki != null && state == ChootyState.Running && can_shoot == true:
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
		if position.distance_to(Cuki.position) > 100 :
			if can_shoot:
				if state != ChootyState.Shooting:
					stateAndAnimationChange(ChootyState.Shooting)
			else: 
				stateAndAnimationChange(ChootyState.Resting)
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

func shoot_stone():
	var stone = STONE.instantiate()
	stone.global_position = global_position
	if Cuki != null:
		stone.objective_position = Cuki.global_position
	call_deferred("add_sibling",stone)

func defeat():
	self.queue_free()

func attackedBySomething(healthLost):
	health_bar.show()
	hide_timer.start()
	health.current -= healthLost

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki":
			Cuki = body

func _on_vision_field_body_exited(body):
	if body.get_name() == "Cuki":
		Cuki = null

func _on_shoot_timer_timeout():
	can_shoot = true

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Shoot":
			shoot_timer.start()
			can_shoot = false

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		attackedBySomething(1)
	if area.is_in_group("expl_attack") || area.is_in_group("expl_bun"):
		attackedBySomething(3)
