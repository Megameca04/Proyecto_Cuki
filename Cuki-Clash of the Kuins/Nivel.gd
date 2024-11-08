extends Node2D

@export var Cuki : CharacterBody2D
@onready var HealthBar := $CanvasUI/PlayerUI/BarraSalud

func _ready():
	Cuki.health.connect("changed",Callable(HealthBar,"set_value"))
	Cuki.health.connect("max_changed",Callable(HealthBar,"set_max"))
	Cuki.health.initialize()
