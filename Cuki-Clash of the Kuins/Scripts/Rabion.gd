extends KinematicBody2D

var Cuki = null #objetivo actual

var knockback = Vector2() #vector de knockback
var movement = Vector2()  #vector de movimiento

export (int) var speed = 100 #velocidad del enemigo

func _process(delta): #ciclo principal del juego
	animations()

func _physics_process(delta): #ciclo del movimiento
	movement = Vector2.ZERO #reinicio del vector de movimiento
	
	#realiza el knocback
	knockback = knockback.move_toward(Vector2.ZERO,200)
	knockback = move_and_slide(knockback)
	
	if Cuki != null: #si hay objetivo en el area de visión
		movement = position.direction_to(Cuki.position) * speed #direction_to da un vector unitario, este se multiplica por la velocidad
	else:
		movement = Vector2.ZERO #si no hay enemigo, se establece en vector nulo
	
	movement = move_and_slide(movement) #realiza el movimiento
	

func _on_VisionField_body_entered(body): #si un cuerpo entra al area de visión
	if body != self: #si no es sí mismo
		if body.get_name() == "Cuki": #si el cuerpo es Cuki
			Cuki = body #el objetivo será igual al cuerpo que entró

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
