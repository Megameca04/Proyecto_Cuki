extends Node

const CORAZON = preload("res://Entidades/Elementos combates/Vida.tscn")

var rng = RandomNumberGenerator.new() 

func generar_vida(muerte):
	
	match muerte:
		0:
			var elec = rng.randi_range(1,10)
			
			if elec <= 10:
				var cor = CORAZON.instantiate()
				cor.position = get_parent().position
				get_parent().get_parent().call_deferred("add_child",cor)
	
