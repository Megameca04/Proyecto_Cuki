extends Area2D

var element : int :
	
	set(value):
		
		value = clamp(value, 0, 6)
		var color_to_modulate : Color 
		
		match value:
			0: #Nulo
				color_to_modulate = Color(1, 1, 1)
			1: #Fuego
				color_to_modulate = Color(1, 0, 0)
			2: #Rayo
				color_to_modulate = Color(0.8, 0.8, 0.8)
			3: #Agua
				color_to_modulate = Color(0, 0, 1)
			4: #Hielo
				color_to_modulate = Color(0.5, 0.7, 0)
			5: #Veneno
				color_to_modulate = Color (0, 1, 0)
			6: #Alquitran
				color_to_modulate = Color(0.5, 0, 0.5)
		
		element = value
		$Sprite2D.modulate = color_to_modulate
	get:
		return(element)

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
