extends Area2D

var element = ""

func _on_timer_timeout():
	self.queue_free()