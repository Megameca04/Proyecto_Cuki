extends CharacterBody2D

const GROUND_SLAM = preload("res://Entidades/Explosion.tscn")

enum STATES {idle, walk, hurt, attacking, recover, dashing}
enum ATTACKS {none, hit1, hit2, hit3, hit4}
var level = 4
var current_state = STATES.idle
var current_attack = ATTACKS.none
var next_attack = current_attack
var can_next = false
var attack_counter = 0

@export var speed = 200 

var direction = Vector2.ZERO
var movement = Vector2()
var knockback = Vector2()

@onready var health = $Salud 
@onready var health_bar = $Health_bar

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"game_over"))
	health.initialize()

func _process(delta):
	$Label.text ="CA: " + str(current_attack) + " NA: "+ str(next_attack)
	$Label2.text = "CS: "+ str(current_state)+"\nYa: "+str(can_next)

func _physics_process(delta):
	CukiDirections()
	attack()
	calcularMovimiento()
	moviendose()
	animations() 
	

func CukiDirections():
	direction = Vector2.ZERO
	if current_state == STATES.walk or current_state == STATES.idle or current_state == STATES.dashing:
		if Input.is_action_pressed("ui_up"):
			direction.y = -1
		if Input.is_action_pressed("ui_down"):
			direction.y = 1
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
		if Input.is_action_pressed("ui_right"):
			direction.x = 1

func calcularMovimiento():
	movement = Vector2.ZERO
	movement = direction.normalized()
	if current_state == STATES.dashing:
		movement *= 2

func moviendose():
	set_velocity((movement*speed) + knockback)
	move_and_slide()
	movement = velocity

func animations():	
	match current_state:
		STATES.idle:
			knockback = Vector2.ZERO
			$Anim_Sprite.play("Stay")
			if movement != Vector2.ZERO and current_state != STATES.dashing:
				current_state = STATES.walk
		STATES.walk:
			knockback = Vector2.ZERO
			$Anim_Sprite.play("Walking")
			if direction.x >= 1:
				$Sprite2D.scale.x = 1
				$CollisionShape2D.scale.x = 1
			elif direction.x <= -1:
				$Sprite2D.scale.x = -1
				$CollisionShape2D.scale.x = -1
			if movement == Vector2.ZERO and current_state != STATES.dashing:
				current_state = STATES.idle
		STATES.dashing:
			knockback = Vector2.ZERO
			$Anim_Sprite.play("Dash")
			if direction.x >= 1:
				$Sprite2D.scale.x = 1
				$CollisionShape2D.scale.x = 1
			elif direction.x <= -1:
				$Sprite2D.scale.x = -1
				$CollisionShape2D.scale.x = -1
			if movement == Vector2.ZERO and current_state != STATES.dashing:
				current_state = STATES.idle
		STATES.hurt:
			$Anim_Sprite.play("Hurt")
			if direction.x >= 1:
				$Sprite2D.scale.x = 1
				$CollisionShape2D.scale.x = 1
			elif direction.x <= -1:
				$Sprite2D.scale.x = -1
				$CollisionShape2D.scale.x = -1
		STATES.attacking:
			knockback = Vector2.ZERO
			current_attack = next_attack
			match current_attack:
				ATTACKS.hit1:
					$Anim_Sprite.play("Hit_1")
				ATTACKS.hit2:
					$Anim_Sprite.play("Hit_2")
				ATTACKS.hit3:
					$Anim_Sprite.play("Hit_3")
				ATTACKS.hit4:
					$Anim_Sprite.play("Hit_4")
		STATES.recover:
			$Anim_Sprite.play("Recover")

func attack():
	if Input.is_action_just_pressed("Atacar"):
		if current_state != STATES.recover and current_state != STATES.dashing and current_state != STATES.hurt:
			current_state = STATES.attacking
			match current_attack:
				ATTACKS.none:
					next_attack = ATTACKS.hit1
				ATTACKS.hit1:
						if can_next and level >= ATTACKS.hit2:
							if next_attack != ATTACKS.hit2:
								can_next = false
								next_attack = ATTACKS.hit2
				ATTACKS.hit2:
					if can_next and level >= ATTACKS.hit3:
						if next_attack != ATTACKS.hit3:
							can_next = false
							next_attack = ATTACKS.hit3
				ATTACKS.hit3:
					if can_next and level >= ATTACKS.hit4:
						if next_attack != ATTACKS.hit4:
							can_next = false
							next_attack = ATTACKS.hit4
				_: 
					current_attack = ATTACKS.none
	
	if Input.is_action_just_pressed("Dash"):
		if current_state != STATES.dashing and direction != Vector2.ZERO:
			can_next = false
			current_state = STATES.dashing
			$Hitbox/CollisionShape2D.disabled = true
			set_collision_mask_value(2,false)

func attackedBySomething(knockbackForce, healthLost, something):
	current_state = STATES.hurt
	knockback -= knockbackForce*Vector2(cos(get_angle_to(something.position)),sin(get_angle_to(something.position)))
	$Health_bar.show()
	health.current -= healthLost

func keep_combo():
	can_next = true

func stop_combo():
	can_next = false
	$Hitbox/CollisionShape2D.disabled = false
	$CollisionShape2D.disabled = false
	set_collision_mask_value(2,true)
	current_state = STATES.idle
	current_attack = ATTACKS.none
	next_attack = ATTACKS.none

func game_over():
	self.set_physics_process(false)
	self.set_process(false)

func _on_Hitbox_body_entered(body):
		if body.is_in_group("Enemy"):
			attackedBySomething(500, 1, body)

func _on_Anim_Sprite_animation_finished(anim_name):
	match anim_name:
		"Dash":
			stop_combo()
		"Hit_1":
			stop_combo()
		"Hit_2":
			stop_combo()
		"Hit_3":
			can_next = false
			current_state = STATES.recover
			current_attack = ATTACKS.none
			next_attack = ATTACKS.none
		"Recover":
			stop_combo()
		"Hit_4":
			stop_combo()
			var gs = GROUND_SLAM.instantiate()
			gs.add_to_group("Cuki_ground_slam")
			gs.add_to_group("expl_attack")
			gs.global_position = self.global_position
			call_deferred("add_sibling",gs)
		"Hurt":
			if direction == Vector2.ZERO:
				current_state = STATES.idle
			else:
				current_state = STATES.walk
			$Health_bar.hide()

func _on_hitbox_area_entered(area):
	if area.is_in_group("expl_attack") and !area.is_in_group("Cuki_ground_slam"):
		attackedBySomething(750, 1, area)
	if area.is_in_group("expl_blonk"):
		attackedBySomething(750, 1, area)
	if area.is_in_group("Piedra"):
		attackedBySomething(500, 1, area)
