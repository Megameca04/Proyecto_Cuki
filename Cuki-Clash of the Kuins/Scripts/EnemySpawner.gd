extends Marker2D

@export var enemy : PackedScene

@onready var rabion = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rabion == null:
		rabion = enemy.instantiate()
		rabion.global_position = global_position
		add_sibling(rabion)
