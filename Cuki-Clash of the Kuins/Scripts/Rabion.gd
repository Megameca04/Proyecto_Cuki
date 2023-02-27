extends KinematicBody2D

var Cuki = null #objetivo actual

var knockback = Vector2() #vector de knockback
var movement = Vector2()  #vector de movimiento
var formacion = Vector2.ZERO

onready var aliados = get_tree().get_nodes_in_group("Conejos")

onready var health = $Salud #referencia al nodo de salud
onready var health_bar = $Sprite/ProgressBar #referencia al nodo de la barra de vida
onready var hide_timer = $Sprite/Hide_timer #referencia al nodo que oculta la barra de vida

export (int) var speed = 100 #velocidad del enemigo

func _ready():
	#conecta los nodos de salud y barra de salud para que muestre la vida graficamente
	health.connect("changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.connect("depleted", self, "defeat")
	health.initialize()

func _process(delta): #ciclo principal del juego
	animations()

func _physics_process(delta): #ciclo del movimiento
	movement = Vector2.ZERO #reinicio del vector de movimiento
	
	#realiza el knocback
	knockback = knockback.move_toward(Vector2.ZERO,200)
	knockback = move_and_slide(knockback)
	
	aliados = get_tree().get_nodes_in_group("Conejos")
	
	if Cuki != null: #si hay objetivo en el area de visión
		for i in aliados:
			if i != self:
				formacion += Vector2(cos(-get_angle_to(i.position)), sin(-get_angle_to(i.position)))
		
		formacion = formacion.normalized()
		
		movement = position.direction_to(Cuki.position) #direction_to da un vector unitario, este se multiplica por la velocidad
	else:
		movement = Vector2.ZERO #si no hay enemigo, se establece en vector nulo
		formacion = Vector2.ZERO
	
	$Movimiento.cast_to = movement*50
	
	$Formacion.cast_to = formacion*50
	
	movement = ((1.5*movement)+formacion).normalized()
	
	movement = move_and_slide(movement * speed) #realiza el movimiento
	

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
		$Sprite.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif movement.x >= -1:
		$Sprite.scale.x = -1
		$CollisionShape2D.scale.x = -1

func _on_Area2D_area_entered(area): #si entra un area (ataques)
	
	if area.name == "Bat_zone": #si entra un enemigo, ajustar dirección del knockback
		if area.global_position.x < self.global_position.x :
			knockback.x = 1250
		elif area.global_position.x > self.global_position.x:
			knockback.x = -1250
		if area.global_position.y < self.global_position.y :
			knockback.y = 1250
		elif area.global_position.y > self.global_position.y:
			knockback.y = -1250
		
		health.current -= 1
