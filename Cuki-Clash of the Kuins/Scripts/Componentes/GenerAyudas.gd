extends Node

const AYUDA = preload("res://Entidades/Elementos combates/Ayuda.tscn")

static var rng = RandomNumberGenerator.new()

func generar_por_muerte(muerte):
	var elec = _decidir_generar(muerte, 0)
	
	if elec == 1:
		var a = AYUDA.instantiate()
		a.global_position = get_parent().global_position
		a.tipo = 0
		get_parent().get_parent().call_deferred("add_child",a)
	else:
		elec = _decidir_generar(muerte, 1)
		print(elec)
		
		if elec == 1:
			var a = AYUDA.instantiate()
			a.global_position = get_parent().global_position
			a.tipo = 1
			get_parent().get_parent().call_deferred("add_child",a)

func _decidir_generar(muerte, tipo):
	match tipo:
		0:
			match muerte:
				0:
					return rng.randi_range(1,10)
				1: 
					return rng.randi_range(1,5)
				_:
					return 0
		1:
			match muerte:
				0:
					return rng.randi_range(1,8)
				_:
					return 0

func generar_solo_bateria(parent):
	if parent.is_in_group("Barrels") or parent.is_in_group("Enemy_shock_attack"):
		if parent.element == 2:
			var elec = rng.randi_range(1,7)
			
			if elec == 1:
				var a = AYUDA.instantiate()
				a.global_position = get_parent().global_position
				a.tipo = 1
				get_parent().get_parent().call_deferred("add_child",a)
			
	elif parent.is_in_group("Enemy_shock_attack"):
		var elec = rng.randi_range(1,10)
		if elec == 1:
			var a = AYUDA.instantiate()
			a.global_position = get_parent().global_position
			a.tipo = 1
			get_parent().get_parent().call_deferred("add_child",a)
