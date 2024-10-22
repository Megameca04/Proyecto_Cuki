extends EstadoBase

func iniciar():
	
	if (
		nodo_c.elemental_state.getState() != 2 and nodo_c.elemental_state.getState() != 9
		):
		
		nodo_c.direction = Vector2(
			Input.get_axis("ui_left","ui_right"),
			Input.get_axis("ui_up","ui_down")
		)
	
	nodo_c.set_collision_mask_value(2, false)
	nodo_c.hitbox_col.disabled = true
	
	nodo_c.anim_node.play("Dash")
	

func en_process(delta):
	if nodo_c.direction.x >= 1:
		nodo_c.sprite.scale.x = 1
	elif nodo_c.direction.x <= -1:
		nodo_c.sprite.scale.x = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func en_physics_process(delta):
	if nodo_c.elemental_state.getState() != 6:
		nodo_c.movement = nodo_c.direction
		
		if nodo_c.elemental_state.getState() == 4:
			nodo_c.total_speed = nodo_c.speed / 2
		else:
			nodo_c.total_speed = nodo_c.speed
			
		nodo_c.set_velocity( (2*nodo_c.movement * nodo_c.total_speed) + nodo_c.knockback)
		nodo_c.move_and_slide()

func en_input(event : InputEvent):
	if (
		nodo_c.elemental_state.getState() != 2 and nodo_c.elemental_state.getState() != 9
		):
		
		nodo_c.direction = Vector2(
			Input.get_axis("ui_left","ui_right"),
			Input.get_axis("ui_up","ui_down")
		)
		nodo_c.knockback = Vector2.ZERO
	
	
	if (
		nodo_c.anim_node.current_animation_position >= 0.5
		and Input.is_action_just_pressed("Atacar")
	):
		maq_estados.cambiar_estado("JugadorDashAtt")

func detener():
	nodo_c.set_collision_mask_value(2, true)
	nodo_c.hitbox_col.disabled = false
