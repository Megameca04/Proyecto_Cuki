extends Area2D

enum DifficultyLevels { EASY, NORMAL, HARD }
@export var difficulty:DifficultyLevels
@export var rounds = 0
@export var easyEnemiesDictionary = {}
@export var normalEnemiesDictionary = {}
@export var hardEnemiesDictionary = {}
var enemyStates = {0:"Freeze", 1:"Poison", 2:"Flame", 3:"Water", 4:"Tar", 5:"Shock"}
var randomQuantityEnemies = 0
var randomEnemyIndex = 0
var randomEnemyState = 0

func detectPlayer(groupName):
	if (groupName == "Player"):
		generateEnemies()

func detectEnemies(groupName):
	if (groupName == "Enemies"):
		pass

func detectBarrels(groupName):
	if (groupName == "Barrels"):
		pass

func generateEnemies():
	pass

func _on_body_entered(body):
	for i in body.get_groups():
		detectPlayer(i)
		detectEnemies(i)
		detectBarrels(i)
