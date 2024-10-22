extends EstadoBase

func iniciar():
	nodo_c.anim_node.play("ChargingAttack")

func en_physics_process(delta):
	if Input.is_action_pressed("Atacar"):
		nodo_c.charge += delta
	
	if Input.is_action_just_released("Atacar"):
		maq_estados.cambiar_estado("JugadorIdle")

func detener():
	nodo_c.charge = 0
