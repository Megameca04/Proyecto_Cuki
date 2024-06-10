extends Area2D

enum Types {
	HEALTH,
	CHARGE}

@onready var sprite = $Sprite2D

@export var tipo : Types

func _ready():
	sprite.frame = tipo

func _on_body_entered(body):
	if body.name == "Cuki":
		self.queue_free()
