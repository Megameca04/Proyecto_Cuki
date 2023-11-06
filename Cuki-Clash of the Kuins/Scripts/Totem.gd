extends Area2D

enum DifficultyLevels { EASY, NORMAL, HARD }
@export var difficulty:DifficultyLevels
@export var rounds = 0
@onready var rabion = preload("res://Entidades/Rabion.tscn")
@onready var blonk = preload("res://Entidades/blonk.tscn")
@onready var chooty = preload("res://Entidades/Chooty.tscn")
@onready var explosive_eater = preload("res://Entidades/explosive_eater.tscn")
var easyEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Explosive_Eater"}
var normalEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Explosive_Eater"}
var hardEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Explosive_Eater"}
var enemyStates = {0:"Freeze", 1:"Poison", 2:"Flame", 3:"Water", 4:"Tar", 5:"Shock"}
var randomQuantityEnemies = 0
var randomEnemyIndex = 0
var randomEnemyState = 0
var Cuki = null
var enemiesGenerated = false

func _ready():
	randomize()

func detectPlayer(player):
	if (player.name == "Cuki"):
		Cuki = player
		generateEnemies()

func generateEnemies():
	if enemiesGenerated == false:
		enemiesGenerated = true
		var enemy = null
		randomQuantityEnemies = randi() % 10
		for n in randomQuantityEnemies:
			randomEnemyIndex = randi() % 4
			if (easyEnemiesDictionary[randomEnemyIndex] == "Rabion"):
				enemy = rabion.instantiate()
			if (easyEnemiesDictionary[randomEnemyIndex] == "Blonk"):
				enemy = blonk.instantiate()
			if (easyEnemiesDictionary[randomEnemyIndex] == "Chooty"):
				enemy = chooty.instantiate()
			if (easyEnemiesDictionary[randomEnemyIndex] == "Explosive_Eater"):
				enemy = explosive_eater.instantiate()
			var newPosition = Vector2.ZERO
			while newPosition == Vector2.ZERO || newPosition == Cuki.position:
				newPosition = Vector2(randi() % 50, randi() & 50)
			enemy.global_position = newPosition
			self.call_deferred("add_child", enemy)

func _on_body_entered(body):
	detectPlayer(body)
