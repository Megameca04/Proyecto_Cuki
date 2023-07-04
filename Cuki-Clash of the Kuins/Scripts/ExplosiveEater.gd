extends CharacterBody2D

enum ExplosiveEaterState { Chill, SearchingBarrel, Pursuing, Exploding, NormalRabion }
var Cuki = null
var CukiOnAttackRange = null
var barrelToGet = null
var state = ExplosiveEaterState.Chill
var movement = Vector2()
var knockback = Vector2()
const ATTACK = preload("res://Entidades/Explosion.tscn")
@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var attack_spawner = $AttackSpawner
@onready var elemental_state = $ElementalState # Referencia a la barra de estado de los elementos
@export var explosiveEaterSpeed = 100

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(delta):
	animationFace()

func _physics_process(delta):
	explosiveEaterMovement()

func animationFace():
	if movement.x <= 1:
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1
	elif movement.x >= -1:
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1

func stateAndAnimationChange(bunState):
	state = bunState
	if bunState == ExplosiveEaterState.Chill || bunState == ExplosiveEaterState.SearchingBarrel || bunState == ExplosiveEaterState.NormalRabion:
		$AnimationPlayer.play("Empty")
	if bunState == ExplosiveEaterState.Pursuing:
		$AnimationPlayer.play("Full")
	if bunState == ExplosiveEaterState.Exploding:
		$AnimationPlayer.play("Explode")

func explosiveEaterMovement():
	movement = Vector2.ZERO
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen" && elemental_state.getMovementState() != "Tar":
		match state:
			ExplosiveEaterState.Pursuing:
				movement = position.direction_to(Cuki.position)
			ExplosiveEaterState.NormalRabion:
				movement = position.direction_to(Cuki.position)
			ExplosiveEaterState.SearchingBarrel:
				if barrelToGet != null:
					movement = position.direction_to(barrelToGet.position)
				else:
					checkClosestBarrel()
			ExplosiveEaterState.Exploding:
				movement = Vector2.ZERO
		
		if (elemental_state.getMovementState() == "Ice"):
			set_velocity(movement * explosiveEaterSpeed / 2 + knockback)
		else:
			set_velocity((movement * explosiveEaterSpeed) + knockback)
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
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":
		var atk = ATTACK.instantiate()
		atk.add_to_group("expl_bun")
		atk.global_position = attack_spawner.global_position
		call_deferred("add_sibling",atk)
		self.queue_free()

func defeat():
	self.queue_free()

func eatBarrel(body):
	stateAndAnimationChange(ExplosiveEaterState.Pursuing)
	body.queue_free()

func attackedBySomething(knockbackForce, healthLost, something):
	if elemental_state.getMovementState() != "Frozen":
		if something != null:
			knockback = -knockbackForce*Vector2(cos(get_angle_to(something.global_position)),sin(get_angle_to(something.global_position)))
			$Knockback_timer.start()
		health_bar.show()
		hide_timer.start()
		if elemental_state.getMovementState() == "Venom":
			health.current -= healthLost * 2
		else:
			health.current -= healthLost

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki" && state == ExplosiveEaterState.Chill:
		Cuki = body
		checkClosestBarrel()

func _on_hitbox_body_entered(body):
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":
		if body.is_in_group("Barrels") && state == ExplosiveEaterState.SearchingBarrel:
			eatBarrel(body)
		if body.get_name() == "Cuki" && state == ExplosiveEaterState.Pursuing:
			stateAndAnimationChange(ExplosiveEaterState.Exploding)

func _on_attack_area_body_entered(body):
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":
		if body.get_name() == "Cuki" && state == ExplosiveEaterState.Pursuing:
			stateAndAnimationChange(ExplosiveEaterState.Exploding)

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		if state == ExplosiveEaterState.Pursuing:
			attackPlayer()
		else:
			attackedBySomething(350, 1, area)
	if area.is_in_group("expl_attack") || area.is_in_group("expl_blonk"):
		if state == ExplosiveEaterState.Pursuing:
			attackPlayer()
		else:
			attackedBySomething(600, 4, area)
		
		elemental_state.contactWithElement(area.name)
		if (area.name == "Water" && elemental_state.getMovementState() == "Paralyzed"):
			attackedBySomething(0, 1, null)

func _on_hide_timer_timeout():
	health_bar.hide()

func _on_knockback_timer_timeout():
	knockback = Vector2.ZERO

func _on_elemental_state_temporal_damage():
	if (elemental_state.getTemporalState() == "Fire"):
		attackedBySomething(0, 1, null)
	if (elemental_state.getTemporalState() == "IntenseFire"):
		attackedBySomething(0, 1 * 2, null)
