extends CharacterBody2D

enum ExplosiveEaterState { Chill, SearchingBarrel, Pursuing, Exploding }
var Cuki = null
var CukiOnAttackRange = null
var barrelToGet = null
var state = ExplosiveEaterState.Chill
var movement = Vector2()
const ATTACK = preload("res://Entidades/Explosion.tscn")
@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var attack_spawner = $AttackSpawner
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
	if bunState == ExplosiveEaterState.Chill || bunState == ExplosiveEaterState.SearchingBarrel:
		$AnimationPlayer.play("Empty")
	if bunState == ExplosiveEaterState.Pursuing:
		$AnimationPlayer.play("Full")
	if bunState == ExplosiveEaterState.Exploding:
		$AnimationPlayer.play("Explode")

func explosiveEaterMovement():
	if state == ExplosiveEaterState.Pursuing:
		movement = position.direction_to(Cuki.position)
	if state == ExplosiveEaterState.SearchingBarrel && barrelToGet != null:
		movement = position.direction_to(barrelToGet.position)
	if state == ExplosiveEaterState.Exploding:
		movement = Vector2.ZERO
	set_velocity(movement * explosiveEaterSpeed)
	move_and_slide()
	movement = velocity

func checkClosestBarrel():
	var distanceToBarrel = 99999999
	var barrels = get_tree().get_nodes_in_group("Barrels")
	for barrel in barrels:
		if barrel.global_position.distance_to(self.global_position) < distanceToBarrel:
			distanceToBarrel = barrel.global_position.distance_to(self.global_position)
			barrelToGet = barrel
	stateAndAnimationChange(ExplosiveEaterState.SearchingBarrel)

func attackPlayer():
	var atk = ATTACK.instantiate()
	atk.add_to_group("expl_bun")
	atk.global_position = attack_spawner.global_position
	call_deferred("add_sibling",atk)
	self.queue_free()

func eatBarrel(body):
	stateAndAnimationChange(ExplosiveEaterState.Pursuing)
	body.queue_free()

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki" && state == ExplosiveEaterState.Chill:
		Cuki = body
		checkClosestBarrel()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Barrels") && state == ExplosiveEaterState.SearchingBarrel:
		eatBarrel(body)
	if body.get_name() == "Cuki" && state == ExplosiveEaterState.Pursuing:
		stateAndAnimationChange(ExplosiveEaterState.Exploding)

func _on_attack_area_body_entered(body):
	if body.get_name() == "Cuki" && state == ExplosiveEaterState.Pursuing:
		stateAndAnimationChange(ExplosiveEaterState.Exploding)

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		if state == ExplosiveEaterState.Pursuing:
			attackPlayer()
		else:
			health_bar.show()
			hide_timer.start()
			health.current -= 1
	if area.is_in_group("expl_attack") || area.is_in_group("expl_blonk"):
		if state == ExplosiveEaterState.Pursuing:
			attackPlayer()
