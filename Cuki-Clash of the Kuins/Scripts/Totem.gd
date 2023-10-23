extends Area2D

@export var rounds = 0
@export var easyEnemiesDictionary = {}
@export var normalEnemiesDictionary = {}
@export var hardEnemiesDictionary = {}
var enemyStates = {0:"Freeze", 1:"Poison", 2:"Flame", 3:"Water", 4:"Tar", 5:"Shock"}
var randomQuantityEnemies = 0
var randomEnemyIndex = 0
var randomEnemyState = 0

func detectPlayer():
	pass

func detectEnemies():
	pass

func detectBarrels():
	pass

func generateEnemies():
	pass
