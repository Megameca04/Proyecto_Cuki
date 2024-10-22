extends EstadoBase

func iniciar():
	
	if nodo_c.next_an == 0:
		nodo_c.anim_node.play("Hit_1")
	else:
		nodo_c.anim_node.play("Hit_2")
	
	nodo_c.can_charge = true

func en_physics_process(delta):
	
	nodo_c.direction = Vector2.ZERO
	nodo_c.knockback = Vector2.ZERO
	
	if Input.is_action_just_released("Atacar"):
		nodo_c.can_charge = false
