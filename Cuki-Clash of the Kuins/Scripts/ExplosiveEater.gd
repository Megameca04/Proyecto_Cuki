extends Node

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
@export var explosiveEaterSpeed = 50

func _ready():
	pass


func _process(delta):
	pass
