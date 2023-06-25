extends CharacterBody2D

var Cuki = null #objetivo actual

var knockback = Vector2() #vector de knockback
var movement = Vector2()  #vector de movimiento
var formacion = Vector2.ZERO

@onready var aliados = get_tree().get_nodes_in_group("Conejos")

@onready var health = $Salud #referencia al nodo de salud
@onready var health_bar = $ProgressBar #referencia al nodo de la barra de vida
@onready var hide_timer = $Hide_timer #referencia al nodo que oculta la barra de vida

@export var speed = 100 #velocidad del enemigo

var in_knockback

func _ready():
	#conecta los nodos de salud y barra de salud para que muestre la vida graficamente
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(delta): #ciclo principal del juego
	animations()

func _physics_process(delta): #ciclo del movimiento
	formando()
	calcularMovimiento()
	moviendose()

func formando():
	aliados = get_tree().get_nodes_in_group("Conejos")
	if Cuki != null: #si hay objetivo en el area de visión
		for i in aliados:
			if i != self:
				formacion += Vector2(cos(-get_angle_to(i.position)), sin(-get_angle_to(i.position)))
		formacion = formacion.normalized()
	else:
		formacion = Vector2.ZERO

func calcularMovimiento():
	movement = Vector2.ZERO
	if Cuki != null and !in_knockback:
		movement = position.direction_to(Cuki.position) #direction_to da un vector unitario, este se multiplica por la velocidad
	else:
		movement = Vector2.ZERO
	movement = ((1.5*movement)+formacion).normalized()

func moviendose():
	set_velocity(movement * speed + knockback)
	move_and_slide()
	movement = velocity #realiza el movimiento

func defeat():
	self.queue_free()

func _on_VisionField_body_entered(body): #si un cuerpo entra al area de visión
	if body != self: #si no es sí mismo
		if body.get_name() == "Cuki": #si el cuerpo es Cuki
			Cuki = body #el objetivo será igual al cuerpo que entró
			for i in aliados:
				if i.Cuki == null:
					i.Cuki = Cuki

func _on_VisionField_body_exited(body): #si un cuerpo sale del area de visión
	if body.get_name() == "Cuki": #si ese cuerpo es Cuki
		Cuki = null #vacia el objetivo

func animations():
	if movement.x or movement.y !=0: #si se está moviendo
		$AnimationPlayer.play("Movin")
	else:
		$AnimationPlayer.play("Stay")
	
	if movement.x <= 1: #dirección a la que mira
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif movement.x >= -1:
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1

func _on_Area2D_area_entered(area): #si entra un area (ataques)
	
	if area.is_in_group("C_attack"): #si entra un enemigo, ajustar dirección del knockback
		in_knockback = true #activa el knockback
		#ajuste de componentes X e Y del vector del Knocback
		knockback -= 350*Vector2(cos(get_angle_to(area.get_parent().global_position)),sin(get_angle_to(area.get_parent().global_position)))
		$Knockback_timer.start() #activa el temporizador del knocback
		health_bar.show() #mostrar salud
		hide_timer.start() #cuando se desactiva la salud
		health.current -= 1 #reduce salud
	
	if area.is_in_group("expl_attack") || area.is_in_group("expl_bun"):
		knockback -= 600*Vector2(cos(get_angle_to(area.position)),sin(get_angle_to(area.position)))
		$Knockback_timer.start() #activa el temporizador del knocback
		health_bar.show() #mostrar salud
		hide_timer.start() #cuando se desactiva la salud
		health.current -= 4
	

func _on_hide_timer_timeout():
	health_bar.hide()

func _on_knockback_timer_timeout():
	in_knockback = false
	knockback = Vector2.ZERO

func _on_hitbox_body_entered(body):
	if body.name == "Cuki":
		knockback -= 100*Vector2(cos(get_angle_to(body.position)),sin(get_angle_to(body.position)))
		$Knockback_timer.start()

