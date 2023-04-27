extends CharacterBody2D

enum ExplosiveEaterState { Chill, SearchingBarrel, Pursuing }
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
	pass

func _physics_process(delta):
	explosiveEaterMovement()

func explosiveEaterMovement():
	if state == ExplosiveEaterState.Pursuing:
		movement = position.direction_to(Cuki.position)
	if state == ExplosiveEaterState.SearchingBarrel && barrelToGet != null:
		movement = position.direction_to(barrelToGet.position)
	set_velocity(movement * explosiveEaterSpeed)
	move_and_slide()
	movement = velocity

func checkClosestBarrel():
	var distanceToBarrel = 99999999999999999999
	var barrels = get_tree().get_nodes_in_group("Barrels")
	for barrel in barrels:
		if barrel.global_position.distance_to(self.global_position) < distanceToBarrel:
			distanceToBarrel = barrel.global_position.distance_to(self.global_position)
			barrelToGet = barrel

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki" && state == ExplosiveEaterState.Chill:
		Cuki = body
		state = ExplosiveEaterState.SearchingBarrel
		checkClosestBarrel()
