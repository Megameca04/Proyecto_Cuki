extends Area2D

enum DifficultyLevels { EASY, NORMAL, HARD }
@export var difficulty:DifficultyLevels
@export var rounds = 0
@onready var rabion = preload("res://Entidades/Enemigos/Rabion.tscn")
@onready var blonk = preload("res://Entidades/Enemigos/Blonk.tscn")
@onready var chooty = preload("res://Entidades/Enemigos/Chooty.tscn")
@onready var bum = preload("res://Entidades/Enemigos/Bum.tscn")
@onready var barrel_to_eat = preload("res://Entidades/Elementos combates/Barril.tscn")
var easyEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"bum"} # La cantidad de enemigos que aparecen. Subdificultad por rounds. En cada round hay un tope de enemigos que pueden salir. Determina que tipo de enemigos puede salir.
var normalEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"bum"}
var hardEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"bum"}
var enemyStates = {0:"Freeze", 1:"Poison", 2:"Flame", 3:"Water", 4:"Tar", 5:"Shock"}
var currentRound = 0
var randomQuantityEnemies = 0
var randomEnemyIndex = 0
var randomEnemyState = 0
var Cuki = null
var enemiesGenerated = false
var activated = false

func _ready():
	randomize()

func detectPlayer(player):
	if (player.name == "Cuki"):
		Cuki = player
		generateEnemies()
		activated = true

func generateEnemies():
	if enemiesGenerated == false && activated == true:
		enemiesGenerated = true
		var enemy = null
		var barrel = null
		randomQuantityEnemies = 0
		while randomQuantityEnemies == 0:
			randomQuantityEnemies = randi() % 3
		for n in randomQuantityEnemies:
			randomEnemyIndex = randi() % 4
			if (easyEnemiesDictionary[randomEnemyIndex] == "Rabion"):
				enemy = rabion.instantiate()
				barrel = null
			if (easyEnemiesDictionary[randomEnemyIndex] == "Blonk"):
				enemy = blonk.instantiate()
				barrel = null
			if (easyEnemiesDictionary[randomEnemyIndex] == "Chooty"):
				enemy = chooty.instantiate()
				barrel = null
			if (easyEnemiesDictionary[randomEnemyIndex] == "bum"):
				enemy = bum.instantiate()
				barrel = barrel_to_eat.instantiate()
			var newPosition = Vector2.ZERO
			while newPosition == Vector2.ZERO || newPosition.distance_to(Cuki.position) < 130:
				newPosition = self.global_position
				newPosition += Vector2(randi() % 100, randi() % 100)
			enemy.global_position = newPosition
			enemy.add_to_group("totem_enemies")
			self.call_deferred("add_sibling", enemy)
			if (barrel != null):
				newPosition = self.global_position
				newPosition += Vector2(randi() % 100, randi() % 100)
				barrel.global_position = newPosition
				self.call_deferred("add_sibling", barrel)

func roundEnding():
	currentRound += 1
	enemiesGenerated = false
	if (currentRound == rounds):
		self.queue_free()

func _process(delta):
	if activated == true && get_tree().get_nodes_in_group("totem_enemies").size() == 0:
		roundEnding()
		generateEnemies()

func _on_body_entered(body):
	detectPlayer(body)
