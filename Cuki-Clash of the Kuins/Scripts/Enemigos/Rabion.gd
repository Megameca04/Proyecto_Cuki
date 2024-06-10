extends CharacterBody2D

@export var speed = 100 

var Cuki = null

var knockback = Vector2()
var movement = Vector2()
var formacion = Vector2.ZERO

var last_hit_from = 2

@onready var aliados = get_tree().get_nodes_in_group("Conejos")

@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var elemental_state = $ElementalState

func _ready():
	
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(_delta):
	last_hit_from = 2
	animations()

func _physics_process(_delta):
	formando()
	calcularMovimiento()
	moviendose()

func formando():
	
	if elemental_state.getState() != 2 and elemental_state.getState() != 9:
		aliados = get_tree().get_nodes_in_group("Conejos")
		
		if Cuki != null:
			
			for i in aliados:
				
				if i != self:
					
					formacion += Vector2(cos(-get_angle_to(i.position)),
							sin(-get_angle_to(i.position)))
					
			formacion = formacion.normalized()
		else:
			formacion = Vector2.ZERO

func animations():
	
	if movement.x or movement.y !=0:
		$AnimationPlayer.play("Movin")
	else:
		$AnimationPlayer.play("Stay")
	
	if movement.x <= 1:
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif movement.x >= -1:
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1

func calcularMovimiento():
	movement = Vector2.ZERO
	if elemental_state.getState() != 2 && elemental_state.getState() != 9:
		if Cuki != null:
			movement = position.direction_to(Cuki.position)
		else:
			movement = Vector2.ZERO
		movement = ((3*movement)+formacion).normalized()

func moviendose():
	if elemental_state.getState() != 6:
		
		if elemental_state.getState() == 4:
			set_velocity(movement * (speed / 2) + knockback)
		else:
			set_velocity(movement * speed + knockback)
		
		move_and_slide()
		movement = velocity

func defeat():
	$GenerAyudas.generar_por_muerte(last_hit_from)
	self.queue_free()

func _on_VisionField_body_entered(body):
	if elemental_state.getState() != 2 and elemental_state.getState() != 4:
		
		if body != self:
			
			if body.get_name() == "Cuki":
				
				Cuki = body
				
				for i in aliados:
					if i.Cuki == null:
						i.Cuki = Cuki

func _on_VisionField_body_exited(body):
	if elemental_state.getState() != 2 and elemental_state.getState() != 4:
		if body.get_name() == "Cuki":
			Cuki = null

func _on_Area2D_area_entered(area):
	
	if elemental_state.getState() != 4:
		
		if area.is_in_group("C_attack"):
			
			last_hit_from = 0
			
			if elemental_state.getState() == 5:
				attackedBySomething(350,2,area)
			else:
				attackedBySomething(350,1,area)

		
		if area.is_in_group("expl_attack") or area.is_in_group("expl_bun"):
			
			knockback -= 600*Vector2(cos(get_angle_to(area.global_position)),sin(get_angle_to(area.global_position)))
			$Knockback_timer.start()
			health_bar.show()
			hide_timer.start()
			
			if elemental_state.getState() == 5:
				health.current -= 4 * 2
			else:
				health.current -= 4
			
			elemental_state.contactWithElement(area.name)
			
			if (area.get_parent().name != "Cuki" and area.element == 4 and elemental_state.getState() == 2):
				health.current -= 1
			
			last_hit_from = 1

func elemental_damage(element):
	elemental_state.contactWithElement(element)

func attackedBySomething(knockbackForce, healthLost, something):
	if (something != null):
		knockback = -knockbackForce*Vector2(cos(get_angle_to(something.global_position)),
				sin(get_angle_to(something.global_position)))
	$Knockback_timer.start()
	health.current -= healthLost

func _on_hide_timer_timeout():
	health_bar.hide()

func _on_knockback_timer_timeout():
	knockback = Vector2.ZERO

func _on_elemental_state_temporal_damage():
	if (elemental_state.getState() == 1):
		attackedBySomething(0, 1, null)
	
	if (elemental_state.getState() == 7):
		attackedBySomething(0, 2, null)
	
	if (elemental_state.getState() == 8):
		attackedBySomething(0, 1, null)

func _on_hitbox_body_entered(body):
	if body.name == "Cuki":
		knockback -= 100*Vector2(cos(get_angle_to(body.position)),
				sin(get_angle_to(body.position)))
		$Knockback_timer.start()

