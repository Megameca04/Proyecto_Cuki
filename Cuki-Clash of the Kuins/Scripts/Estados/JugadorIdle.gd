extends EstadoBase

func iniciar():
	nodo_c.anim_node.play("Idle")
	
	if (Input.get_axis("ui_left","ui_right") != 0 or
		Input.get_axis("ui_up","ui_down") != 0):
		maq_estados.cambiar_estado("JugadorMovim")

func en_physics_process(delta):
	
	nodo_c.direction = Vector2.ZERO
	nodo_c.knockback = Vector2.ZERO

func en_process(delta):
	nodo_c.anim_node.play("Idle")

func en_input(event : InputEvent):
	if (Input.get_axis("ui_left","ui_right") != 0 or
		Input.get_axis("ui_up","ui_down") != 0):
		maq_estados.cambiar_estado("JugadorMovim")
		return
	
	if (Input.is_action_just_pressed("Atacar")):
		maq_estados.cambiar_estado("JugadorAtaque")
	
