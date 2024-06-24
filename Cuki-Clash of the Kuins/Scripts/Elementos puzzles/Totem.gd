class_name Totem
extends StaticBody2D

enum DifficultyLevels { EASY, NORMAL, HARD }

const ENEMIES_POOL = {
	"Rabion" : preload("res://Entidades/Enemigos/Rabion.tscn"),
	"Blonk"  : preload("res://Entidades/Enemigos/Blonk.tscn"),
	"Chooty" : preload("res://Entidades/Enemigos/Chooty.tscn"),
	"Bum"    : preload("res://Entidades/Enemigos/Bum.tscn"),
	"Barrel" : preload("res://Entidades/Elementos combates/Barril.tscn")
}

@export var difficulty : DifficultyLevels

@export var rounds := 0 :
	set(v):
		rounds = clamp(v,1,5)

@export var colorhex:String = ""

static var easyEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Bum"} # La cantidad de enemigos que aparecen. Subdificultad por rounds. En cada round hay un tope de enemigos que pueden salir. Determina que tipo de enemigos puede salir.
static var normalEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Bum"}
static var hardEnemiesDictionary = {0:"Rabion", 1:"Blonk", 2:"Chooty", 3:"Bum"}
static var enemyStates = {0:"Freeze", 1:"Poison", 2:"Flame", 3:"Water", 4:"Tar", 5:"Shock"}

var currentRound = 0
var randomQuantityEnemies = 0
var randomEnemyIndex = 0
var randomEnemyState = 0
var Cuki = null
var enemiesGenerated = false
var activated = false
var state = true

func _ready():
	randomize()

func detectPlayer(player):
	if (player.name == "Cuki"):
		Cuki = player
		generateEnemies()
		activated = true
		state = false

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
			
			var choosen_enemy = easyEnemiesDictionary[randomEnemyIndex]
			
			enemy = ENEMIES_POOL[choosen_enemy].instantiate()
			
			if choosen_enemy == "Bum":
				barrel = ENEMIES_POOL["Barrel"].instantiate()
			
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
	if (currentRound == 1+rounds):
		state = true
		return
	currentRound += 1
	enemiesGenerated = false
	

func _process(delta):
	if activated == true && get_tree().get_nodes_in_group("totem_enemies").size() == 0:
		roundEnding()
		generateEnemies()

func _on_body_entered(body):
	detectPlayer(body)
