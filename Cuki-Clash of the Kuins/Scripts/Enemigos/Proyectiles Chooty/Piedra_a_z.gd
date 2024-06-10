extends Area2D

var element : int

func _ready():
	$Timer.start()

func _on_timer_timeout():
	self.queue_free()
