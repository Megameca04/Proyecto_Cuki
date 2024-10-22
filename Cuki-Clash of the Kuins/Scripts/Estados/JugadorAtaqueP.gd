extends EstadoBase

func iniciar():
	nodo_c.anim_node.play("ChargedAttack")

func detener():
	var gs = nodo_c.GROUND_SLAM.instantiate()
	gs.global_position = nodo_c.global_position
	gs.collision_mask = 18
	gs.add_to_group("expl_attack")
	nodo_c.call_deferred("add_sibling",gs)
