extends EstadoBase

func iniciar():
	nodo_c.anim_node.play("Hurt")

func en_physics_process(delta):
	if nodo_c.elemental_state.getState() != 6:
		
		nodo_c.set_velocity(nodo_c.knockback)
		nodo_c.move_and_slide()

func detener():
	nodo_c.knockback = Vector2.ZERO
