extends Node

const CORAZON = preload("res://Entidades/Vida.tscn")

var rng = RandomNumberGenerator.new() 

func generar_vida(muerte):
	
	match muerte:
		0:
			var elec = rng.randi_range(1,10)
			
			if elec == 1:
				var cor = CORAZON.instantiate()
				
				cor.global_position = get_parent().global_position
				get_parent().add_sibling(cor)
	
