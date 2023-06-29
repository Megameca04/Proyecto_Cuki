extends CharacterBody2D

const GROUND_SLAM = preload("res://Entidades/Explosion.tscn")

enum STATES {idle,
			walk,
			hurt,
			attacking,
			recover,
			dashing,
			dAttack,
			chargingA,
			chargedA}

var next_state = STATES.idle
var current_state = next_state

var next_an = 0
var charge = 0

@export var speed = 200
var totalSpeed = 0

var direction = Vector2.ZERO
var movement = Vector2()
var knockback = Vector2()

@onready var health = $Salud 
@onready var health_bar = $Health_bar
@onready var anim_node = $Anim_Sprite
@onready var hitbox_col = $Hitbox/CollisionShape2D
@onready var colision_s = $CollisionShape2D
@onready var attack_node = $Attack_node
@onready var charge_particles = $Charge_particles
@onready var elemental_state = $ElementalState

var can_spin:bool = false
var can_charge: bool = false

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"game_over"))
	health.initialize()

func _physics_process(delta):
	CukiDirections()
	calcularMovimiento()
	moviendose()
	attack(delta)
	animations()
	$Label.text = str(current_state)

func CukiDirections():
	direction = Vector2.ZERO
	if (current_state == STATES.walk || current_state == STATES.idle || current_state == STATES.dashing) && elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":

		if Input.is_action_pressed("ui_up"):
			direction.y = -1
		if Input.is_action_pressed("ui_down"):
			direction.y = 1
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
		if Input.is_action_pressed("ui_right"):
			direction.x = 1
		direction = direction.normalized()
	if direction != Vector2.ZERO and next_state != STATES.dAttack and current_state != STATES.dAttack and current_state != STATES.hurt:
		match next_state:
			STATES.dashing:
				next_state = STATES.dashing
				set_collision_mask_value(2, false)
			STATES.hurt:
				next_state = STATES.hurt
			_:
				next_state = STATES.walk
		attack_node.rotation = direction.angle()
	else:
		if next_state != STATES.attacking and next_state != STATES.chargedA and next_state != STATES.dAttack and next_state != STATES.hurt and current_state != STATES.hurt:
			next_state = STATES.idle

func calcularMovimiento():
	if elemental_state.getMovementState() != "Tar":
		movement = Vector2.ZERO
		movement = direction.normalized()
		if current_state == STATES.dashing:
			movement *= 2
		if elemental_state.getTemporalState() == "Ice":
			totalSpeed = speed / 2
		else:
			totalSpeed = speed

func moviendose():
	if elemental_state.getMovementState() != "Tar":
		set_velocity((movement*totalSpeed) + knockback)
		move_and_slide()
		movement = velocity

func animations():
	if current_state != next_state:
		#print("CS: "+str(current_state)+"|NS: "+str(next_state))
		current_state = next_state
	
	if direction.x >= 1:
		$Sprite2D.scale.x = 1
	elif direction.x <= -1:
		$Sprite2D.scale.x = -1
	
	match current_state:
		STATES.idle:
			knockback = Vector2.ZERO
			anim_node.play("Stay")
		STATES.walk:
			knockback = Vector2.ZERO
			anim_node.play("Walking")
		STATES.dashing:
			knockback = Vector2.ZERO
			anim_node.play("Dash")
			if direction.x >= 1:
				$Sprite2D.scale.x = 1
			elif direction.x <= -1:
				$Sprite2D.scale.x = -1
		STATES.attacking:
			if current_state != STATES.dashing:
				if next_an == 0:
					anim_node.play("Hit_1")
				else:
					anim_node.play("Hit_2")
		STATES.dAttack:
			anim_node.play("Spin_attack")
		STATES.chargingA:
			anim_node.play("ChargingAttack")
		STATES.chargedA:
			anim_node.play("ChargedAttack")
		STATES.hurt:
			anim_node.play("Hurt")
			if direction.x >= 1:
				$Sprite2D.scale.x = 1
			elif direction.x <= -1:
				$Sprite2D.scale.x = -1
	
	if current_state != STATES.chargingA:
		charge_particles.emitting = false
	
	set_collision_mask_value(2, current_state != STATES.dashing || current_state != STATES.dAttack)
	hitbox_col.disabled = (current_state == STATES.dashing || current_state == STATES.dAttack)


func attack(delta):
	if Input.is_action_just_pressed("Atacar") and (next_state != STATES.dAttack or next_state != STATES.hurt) and (current_state != STATES.hurt):
		match current_state:
			STATES.dashing:
				if can_spin:
					next_state = STATES.dAttack
				else:
					next_state = STATES.dashing
			
			_:
				if (current_state != STATES.dAttack or current_state != STATES.hurt) and (next_state != STATES.dAttack or next_state != STATES.hurt):
					next_state = STATES.attacking
					can_charge = false
	
	if Input.is_action_pressed("Atacar") and current_state != STATES.attacking:
		if current_state != STATES.dAttack and next_state != STATES.dAttack and current_state != STATES.hurt and next_state != STATES.hurt and current_state != STATES.dashing and next_state != STATES.dashing:
			if can_charge:
				next_state = STATES.chargingA
				charge += (1*delta)
				if charge >= 1 and (next_state != STATES.chargedA or next_state != STATES.dAttack):
					next_state = STATES.chargedA

	if Input.is_action_just_released("Atacar"):
		charge = 0
		can_charge = false
		if current_state != STATES.chargedA:
			if (current_state != STATES.dAttack and next_state != STATES.dAttack ) and (current_state != STATES.hurt and next_state != STATES.hurt):
				next_state = STATES.attacking
		else:
			next_state = STATES.chargedA
	
	if Input.is_action_just_pressed("Dash"):
		if (current_state != STATES.dashing or current_state != STATES.hurt) and next_state != STATES.hurt and direction != Vector2.ZERO:
			next_state = STATES.dashing

func attackedBySomething(knockbackForce, healthLost, something):
	next_state = STATES.hurt
	knockback -= knockbackForce*Vector2(cos(get_angle_to(something.position)),sin(get_angle_to(something.position)))
	$Knockback_timer.start()
	$Health_bar.show()
	health.current -= healthLost

func game_over():
	self.set_physics_process(false)
	self.set_process(false)

func _on_Hitbox_body_entered(body):
		if body.is_in_group("Enemy"):
			attack_node.rotation = attack_node.global_position.angle_to(body.global_position)
			attackedBySomething(200, 1, body)

func prepare_spin():
	can_spin = true

func _on_Anim_Sprite_animation_finished(anim_name):
	match anim_name:
		"Hit_1":
			next_an = 1
			next_state = STATES.idle
			can_charge = true
		"Hit_2":
			next_an = 0
			next_state = STATES.idle
			can_charge = true
		"Dash":
			can_spin = false
			next_state = STATES.walk
		"Spin_attack":
			can_spin = false
			next_state = STATES.walk
		"Hurt":
			if direction == Vector2.ZERO:
				next_state = STATES.idle
			else:
				next_state = STATES.walk
			$Health_bar.hide()
		"ChargingAttack":
			if charge >= 1:
				next_state = STATES.chargedA
			else:
				next_state = STATES.idle
			charge = 0
		"ChargedAttack":
			next_state = STATES.idle
			charge = 0
			var gs = GROUND_SLAM.instantiate()
			gs.name = "None"
			gs.element_appear("None")
			gs.global_position = self.global_position
			gs.add_to_group("Cuki_ground_slam")
			gs.add_to_group("expl_attack")
			self.call_deferred("add_sibling",gs)

func _on_hitbox_area_entered(area):
	if area.is_in_group("expl_attack") and !area.is_in_group("Cuki_ground_slam"):
		attackedBySomething(750, 1, area)
		elemental_state.contactWithElement(area.name)
	if area.is_in_group("expl_blonk"):
		attackedBySomething(750, 1, area)
	if area.is_in_group("Piedra"):
		attackedBySomething(500, 1, area)
	elemental_state.contactWithElement(area.name)
	if (area.name == "Water" && elemental_state.getMovementState() == "Paralyzed"):
		attackedBySomething(0, 1, area)

func _on_elemental_state_temporal_damage():
	if (elemental_state.getTemporalState() == "Fire"):
		attackedBySomething(0, 1, null)
	if (elemental_state.getTemporalState() == "IntenseFire"):
		attackedBySomething(0, 1 * 2, null)

func _on_knockback_timer_timeout():
	if current_state == STATES.hurt:
		current_state = STATES.idle
