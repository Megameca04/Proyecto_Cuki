extends Area2D

enum DifficultyLevels { EASY, NORMAL, HARD }
@export var difficulty:DifficultyLevels
@export var rounds = 0
@onready var rabion = preload("res://Entidades/Rabion.tscn")
@onready var blonk = preload("res://Entidades/blonk.tscn")
@onready var chooty = preload("res://Entidades/Chooty.tscn")
@onready var explosive_eater = preload("res://Entidades/explosive_eater.tscn")
var easyEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Explosive_Eater"}
@export var normalEnemiesDictionary = {}
@export var hardEnemiesDictionary = {}
var enemyStates = {0:"Freeze", 1:"Poison", 2:"Flame", 3:"Water", 4:"Tar", 5:"Shock"}
var randomQuantityEnemies = 0
var randomEnemyIndex = 0
var randomEnemyState = 0
var Cuki = null

func detectPlayer(player):
	if (player.name == "Cuki"):
		Cuki = player
		generateEnemies()

func generateEnemies():
	var enemy = rabion.instantiate()
	enemy.global_position = Vector2.ZERO
	self.call_deferred("add_child", enemy)

func _on_body_entered(body):
	detectPlayer(body)
