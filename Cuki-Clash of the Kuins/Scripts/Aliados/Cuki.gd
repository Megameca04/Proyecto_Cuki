extends CharacterBody2D

enum STATES {
		idle,
		walk,
		hurt,
		attacking,
		recover,
		dashing,
		dAttack,
		chargingA,
		chargedA
	}

const GROUND_SLAM = preload("res://Entidades/Elementos combates/Explosion.tscn")

@export var _speed : float = 200

var _next_state : int = STATES.idle
var _current_state : int = _next_state
var _next_an : int = 0
var _charge : float = 0
var _total_speed : float = 0
var _can_spin:bool = false
var _can_charge: bool = false
var _direction = Vector2.ZERO
var _movement = Vector2()
var _knockback = Vector2()

@onready var health = $Salud 
@onready var health_bar = $Health_bar
@onready var anim_node = $Anim_Sprite
@onready var hitbox_col = $Hitbox/CollisionShape2D
@onready var colision_s = $CollisionShape2D
@onready var attack_node = $Attack_node
@onready var charge_particles = $Charge_particles
@onready var elemental_state = $ElementalState

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

func CukiDirections():
	
	_direction = Vector2.ZERO
	
	if (
			(
				_current_state == STATES.walk or _current_state == STATES.idle
				or _current_state == STATES.dashing
			) 
			and elemental_state.getState() != 2 and elemental_state.getState() != 9
		):
		
		_direction.x = Input.get_axis("ui_left","ui_right")
		_direction.y = Input.get_axis("ui_up","ui_down")
		_direction = _direction.normalized()
	
	if (
			_direction != Vector2.ZERO and _next_state != STATES.dAttack
			and _current_state != STATES.dAttack and _current_state != STATES.hurt
		):
		
		match _next_state:
			
			STATES.dashing:
				_next_state = STATES.dashing
				set_collision_mask_value(2, false)
			STATES.hurt:
				_next_state = STATES.hurt
			_:
				_next_state = STATES.walk
		attack_node.rotation = _direction.angle()
		
	else:
		if (
				_next_state != STATES.attacking and _next_state != STATES.chargedA
				and _next_state != STATES.dAttack and _next_state != STATES.hurt
				and _current_state != STATES.hurt):
			
			_next_state = STATES.idle

func calcularMovimiento():
	
	if elemental_state.getState() != 6:
		
		_movement = Vector2.ZERO
		_movement = _direction.normalized()
		
		if _current_state == STATES.dashing:
			_movement *= 2
		
		if elemental_state.getState() == 4:
			_total_speed = _speed / 2
		else:
			_total_speed = _speed

func moviendose():
	if elemental_state.getState() != 6:
		
		set_velocity( (_movement * _total_speed) + _knockback)
		move_and_slide()
		
		_movement = velocity

func animations():
	
	if _current_state != _next_state:
		#print("CS: "+str(current_state)+"|NS: "+str(next_state))
		_current_state = _next_state
	
	if _direction.x >= 1:
		$Sprite2D.scale.x = 1
	elif _direction.x <= -1:
		$Sprite2D.scale.x = -1
	
	match _current_state:
		
		STATES.idle:
			
			_knockback = Vector2.ZERO
			anim_node.play("Stay")
			
		STATES.walk:
			
			_knockback = Vector2.ZERO
			anim_node.play("Walking")
			
		STATES.dashing:
			
			_knockback = Vector2.ZERO
			anim_node.play("Dash")
			
			if _direction.x >= 1:
				$Sprite2D.scale.x = 1
			elif _direction.x <= -1:
				$Sprite2D.scale.x = -1
			
		STATES.attacking:
			
			if _current_state != STATES.dashing:
				
				if _next_an == 0:
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
			
			if _direction.x >= 1:
				$Sprite2D.scale.x = 1
			elif _direction.x <= -1:
				$Sprite2D.scale.x = -1
	
	if _current_state != STATES.chargingA:
		charge_particles.emitting = false
	
	set_collision_mask_value(2, _current_state != STATES.dashing or _current_state != STATES.dAttack)
	hitbox_col.disabled = (_current_state == STATES.dashing or _current_state == STATES.dAttack)

func attack(delta):
	
	if (
			Input.is_action_just_pressed("Atacar") and
			(
					_next_state != STATES.dAttack or _next_state != STATES.hurt
			)
			and _current_state != STATES.hurt
	):
		
		match _current_state:
			
			STATES.dashing:
				
				if _can_spin:
					
					_next_state = STATES.dAttack
					
				else:
					
					_next_state = STATES.dashing
			
			_:
				if (
						(_current_state != STATES.dAttack or _current_state != STATES.hurt)
						and (_next_state != STATES.dAttack or _next_state != STATES.hurt)
					):
					
					_next_state = STATES.attacking
					_can_charge = false
	
	if Input.is_action_pressed("Atacar") and _current_state != STATES.attacking:
		
		if (
				_current_state != STATES.dAttack and _next_state != STATES.dAttack
				and _current_state != STATES.hurt and _next_state != STATES.hurt
				and _current_state != STATES.dashing and _next_state != STATES.dashing
		):
			
			if _can_charge:
				
				_next_state = STATES.chargingA
				_charge += (1*delta)
				
				if (
						_charge >= 1 and 
						(_next_state != STATES.chargedA or _next_state != STATES.dAttack)
				):
					_next_state = STATES.chargedA
	
	if Input.is_action_just_released("Atacar"):
		
		_charge = 0
		_can_charge = false
		
		if _current_state != STATES.chargedA:
			
			if (
				(_current_state != STATES.dAttack and _next_state != STATES.dAttack )
				and (_current_state != STATES.hurt and _next_state != STATES.hurt)
			):
				_next_state = STATES.attacking
			
		else:
			
			_next_state = STATES.chargedA
	
	if Input.is_action_just_pressed("Dash"):
		
		if (
			(_current_state != STATES.dashing or _current_state != STATES.hurt)
			and _next_state != STATES.hurt and _direction != Vector2.ZERO
		):
			
			_next_state = STATES.dashing

func attackedBySomething(knockbackForce, healthLost, something):
	
	_next_state = STATES.hurt
	
	if something != null:
		_knockback -= knockbackForce*Vector2(
				cos(get_angle_to(something.position)),
				sin(get_angle_to(something.position))
		)
	
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
	_can_spin = true

func _on_Anim_Sprite_animation_finished(anim_name):
	
	match anim_name:
		
		"Hit_1":
			_next_an = 1
			_next_state = STATES.idle
			_can_charge = true
		
		"Hit_2":
			_next_an = 0
			_next_state = STATES.idle
			_can_charge = true
		
		"Dash":
			_can_spin = false
			_next_state = STATES.walk
		
		"Spin_attack":
			_can_spin = false
			_next_state = STATES.walk
		
		"Hurt":
			if _direction == Vector2.ZERO:
				_next_state = STATES.idle
			else:
				_next_state = STATES.walk
			$Health_bar.hide()
		
		"ChargingAttack":
			if _charge >= 1:
				_next_state = STATES.chargedA
			else:
				_next_state = STATES.idle
			_charge = 0
		
		"ChargedAttack":
			_next_state = STATES.idle
			_charge = 0
			var gs = GROUND_SLAM.instantiate()
			gs.name = "None"
			gs.global_position = self.global_position
			gs.add_to_group("Cuki_ground_slam")
			gs.add_to_group("expl_attack")
			self.call_deferred("add_sibling",gs)

func _on_hitbox_area_entered(area):
	
	if area.is_in_group("expl_attack"):
		
		if !area.is_in_group("Cuki_ground_slam") and !area.is_in_group("expl_attacked_Cuki"):
			
			attackedBySomething(750, 1, area)
			
			elemental_state.contactWithElement(area.element)
			if area.element == 4 and elemental_state.getState() == 2:
					attackedBySomething(0, 1, area)
	
	if area.is_in_group("expl_blonk"):
		attackedBySomething(750, 1, area)
	
	if area.is_in_group("Piedra"):
		attackedBySomething(500, 1, area)
		elemental_state.contactWithElement(area.element)
		elemental_state.contactWithElementGroup(area.get_groups())
	
	if area.is_in_group("Vida"):
		health.current += 1
		health_bar.show()

func elemental_damage(element):
	elemental_state.contactWithElement(element)

func _on_elemental_state_temporal_damage():
	
	if (elemental_state.getState() == 1):
		attackedBySomething(0, 1, null)
	
	if (elemental_state.getState() == 7):
		attackedBySomething(0, 2, null)
	
	if (elemental_state.getState() == 8):
		attackedBySomething(0, 1, null)

func _on_knockback_timer_timeout():
	if _current_state == STATES.hurt:
		_current_state = STATES.idle
