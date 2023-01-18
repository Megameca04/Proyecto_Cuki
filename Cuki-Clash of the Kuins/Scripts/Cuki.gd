extends KinematicBody2D

export (float) var acceleration = 0.38
export (float) var mass = 500

var direction_x = 0
var direction_y = 0

var speed = acceleration * mass

var velocity = Vector2()
var boom = Vector2()

var can_walk = true

onready var health = $Salud
onready var health_bar = $Sprite/ProgressBar
onready var hide_timer = $Sprite/Hide_Timer

func _ready():
	health.connect("changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.initialize()

func _process(delta):
	if can_walk == true:
		animations()
	attack()

func _physics_process(delta):
	if can_walk == true:
		
		velocity = Vector2(0,0)
		direction_x = 0
		direction_y = 0
	
		if Input.is_action_pressed("ui_up"):
			direction_y = -1
		if Input.is_action_pressed("ui_down"):
			direction_y = 1
		if Input.is_action_pressed("ui_left"):
			direction_x = -1
		if Input.is_action_pressed("ui_right"):
			direction_x = 1
		
		velocity.x = direction_x
		velocity.y = direction_y
		
		velocity = velocity.normalized()
		velocity = move_and_slide(velocity * speed)

func animations():
	if velocity.x or velocity.y !=0:
		$Anim_Sprite.play("Walking")
	else:
		$Anim_Sprite.play("Stay")
	if direction_x >= 1:
		$Sprite.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif direction_x <= -1:
		$Sprite.scale.x = -1
		$CollisionShape2D.scale.x = -1

func _on_Area2D_body_entered(body):
		if body.is_in_group("Enemy"):
			if body.global_position.x < self.global_position.x :
				boom.x = 2000
			elif body.global_position.x > self.global_position.x:
				boom.x = -2000
			if body.global_position.x < self.global_position.x :
				boom.y = -2000
			elif body.global_position.x > self.global_position.x:
				boom.y = 2000
			
			$Sprite/ProgressBar.show()
			$Sprite/Hide_Timer.start()
			$Visual_anim.play("Hurt")
			health.current -= 1
		boom = boom.move_toward(Vector2.ZERO,0)
		boom = move_and_slide(boom)
		

func attack():
	if Input.is_action_pressed("Atacar"):
		can_walk = false
		$Anim_Sprite.play("Punch")

func _on_Anim_Sprite_animation_finished(anim_name):
	if anim_name == "Punch":
		can_walk = true


func _on_Hide_Timer_timeout():
	$Sprite/ProgressBar.hide()
