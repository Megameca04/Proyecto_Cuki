extends Area2D

func _on_area_entered(area):
	if area.is_in_group("expl_attack"):
		if area.element == 1:
			self.queue_free()

func _on_body_entered(body):
	if body.is_in_group("Palanca"):
		body.can_be_used = false


func _on_body_exited(body):
	if body.is_in_group("Palanca"):
		body.can_be_used = true
