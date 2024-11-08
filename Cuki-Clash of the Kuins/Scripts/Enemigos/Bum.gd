extends CharacterBody2D

enum ExplosiveEaterState { Chill, SearchingBarrel, Pursuing, Exploding, NormalRabion }

const ATTACK = preload("res://Entidades/Elementos combates/Explosion.tscn")

var state: int  = ExplosiveEaterState.Chill
var movement : Vector2 = Vector2()
var knockback : Vector2 = Vector2()
var in_knockback : bool = false

var last_hit_from = 2

var Cuki = null
var CukiOnAttackRange = null
var barrelToGet = null

@onready var health = $Salud
@onready var attack_spawner = $AttackSpawner
@onready var elemental_state = $ElementalState # Referencia a la barra de estado de los elementos
@onready var sprite = $Sprite2D
@onready var col_shape = $CollisionShape2D
@onready var animations = $AnimationPlayer
@onready var generAyudas = $GenerAyudas

@export var explosiveEaterSpeed = 100

func _ready():
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(_delta):
	last_hit_from = 2
	animationFace()

func _physics_process(_delta):
	explosiveEaterMovement()

func animationFace():
	if movement.x <= 1:
		sprite.scale.x = -1
		col_shape.scale.x = -1
	elif movement.x >= -1:
		sprite.scale.x = 1
		col_shape.scale.x = 1

func stateAndAnimationChange(bunState):
	state = bunState
	if bunState == ExplosiveEaterState.Chill || bunState == ExplosiveEaterState.SearchingBarrel || bunState == ExplosiveEaterState.NormalRabion:
		animations.play("Empty")
	if bunState == ExplosiveEaterState.Pursuing:
		animations.play("Full")
	if bunState == ExplosiveEaterState.Exploding:
		animations.play("Explode")

func explosiveEaterMovement():
	
	if elemental_state.getState() != 2 and elemental_state.getState() != 9 && elemental_state.getState() != 6:
		
		if state == ExplosiveEaterState.Pursuing or state == ExplosiveEaterState.NormalRabion:
			movement = position.direction_to(Cuki.position)
		
		if state == ExplosiveEaterState.SearchingBarrel and barrelToGet != null:
			movement = position.direction_to(barrelToGet.position)
		
		if state == ExplosiveEaterState.SearchingBarrel and barrelToGet == null:
			checkClosestBarrel()
		
		if state == ExplosiveEaterState.Exploding:
			movement = Vector2.ZERO
		
		if (elemental_state.getState() == 4):
			set_velocity(movement * explosiveEaterSpeed / 2 + knockback)
		else:
			set_velocity(movement * explosiveEaterSpeed + knockback)
		move_and_slide()
		movement = velocity

func checkClosestBarrel():
	var distanceToBarrel = 99999999
	var barrels = get_tree().get_nodes_in_group("Barrels")
	
	for barrel in barrels:
		
		if barrel.global_position.distance_to(self.global_position) < distanceToBarrel:
			
			distanceToBarrel = barrel.global_position.distance_to(self.global_position)
			barrelToGet = barrel
		
	if (barrelToGet != null):
		stateAndAnimationChange(ExplosiveEaterState.SearchingBarrel)
	else:
		stateAndAnimationChange(ExplosiveEaterState.NormalRabion)

func attackPlayer():
	
	if elemental_state.getState() != 2 && elemental_state.getState() != 9:
		var atk = ATTACK.instantiate()
		atk.add_to_group("expl_bun")
		atk.global_position = attack_spawner.global_position
		call_deferred("add_sibling",atk)
		self.queue_free()

func defeat():
	generAyudas.generar_por_muerte(last_hit_from)
	self.queue_free()

func eatBarrel(body):
	stateAndAnimationChange(ExplosiveEaterState.Pursuing)
	body.queue_free()

func attackedBySomething(knockbackForce, healthLost, something):
	if elemental_state.getState() != 9:
		in_knockback = true
		
		knockback -= knockbackForce*Vector2(
				cos(get_angle_to(something.global_position)),
				sin(get_angle_to(something.global_position))
				)
		
		$Knockback_timer.start()
		
		if elemental_state.getState() == 5:
			health.current -= healthLost * 2
		else:
			health.current -= healthLost

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki" && state == ExplosiveEaterState.Chill:
		Cuki = body
		checkClosestBarrel()

func _on_hitbox_body_entered(body):
	if elemental_state.getState() != 2 and elemental_state.getState() != 9:
		if body.is_in_group("Barrels") && state == ExplosiveEaterState.SearchingBarrel:
			eatBarrel(body)
		if body.get_name() == "Cuki" && state == ExplosiveEaterState.Pursuing:
			stateAndAnimationChange(ExplosiveEaterState.Exploding)

func _on_attack_area_body_entered(body):
	
	if elemental_state.getState() != 2 and elemental_state.getState() != 9:
		
		if body.get_name() == "Cuki" && state == ExplosiveEaterState.Pursuing:
			stateAndAnimationChange(ExplosiveEaterState.Exploding)

func elemental_damage(element):
	elemental_state.contactWithElement(element)

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		
		if state == ExplosiveEaterState.Pursuing:
			attackPlayer()
		else:
			last_hit_from = 0
			attackedBySomething(350, 1, area)
		
		
		
	
	if area.is_in_group("expl_attack") || area.is_in_group("expl_blonk"):
		
		if state == ExplosiveEaterState.Pursuing:
			attackPlayer()
		else:
			attackedBySomething(600, 4, area)
		
		if area.is_in_group("Elements"):
			
			elemental_state.contactWithElementGroup(area.get_groups())
			if (area.element == 4 && elemental_state.getState() == 2):
				attackedBySomething(0, 1, area)
		
		last_hit_from = 1

func _on_knockback_timer_timeout():
	in_knockback = false
	knockback = Vector2.ZERO

func _on_elemental_state_temporal_damage():
	if (elemental_state.getTemporalState() == "Fire"):
		attackedBySomething(0, 1, null)
	if (elemental_state.getTemporalState() == "IntenseFire"):
		attackedBySomething(0, 1 * 2, null)
	if (elemental_state.getTemporalState() == "Electroshocked"):
		attackedBySomething(0, 1, null)
