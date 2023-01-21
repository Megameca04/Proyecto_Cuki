extends KinematicBody2D

export (int) var speed = 200 #Velocidad del jugador

var direction = Vector2.ZERO #vector de dirección del jugador
var movement = Vector2() #vector de movimiento del jugador
var knockback = Vector2() #vector de knockback del jugador

var can_walk = true #permite el movimiento, bloqueado en caso de animaciones como golpear

onready var health = $Salud #referencia al nodo de salud
onready var health_bar = $Sprite/ProgressBar #referencia al nodo de la barra de vida
onready var hide_timer = $Sprite/Hide_Timer #referencia al nodo que oculta la barra de vida

func _ready():
	#conecta los nodos de salud y barra de salud para que muestre la vida graficamente
	health.connect("changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.initialize()

func _process(delta): #ciclo principal del juego
	if can_walk == true: #si puede caminar(no está reproduciendo una animación estatica)
		animations() 
	
	attack() #Siempre ataca

func _physics_process(delta):
	if can_walk == true: #si puede caminar
		
		#reinicia el movimiento y la dirección cada frame del juego 
		movement = Vector2.ZERO 
		direction = Vector2.ZERO
		
		#recibe la entrada por teclado del jugador
		if Input.is_action_pressed("ui_up"):
			direction.y = -1
		if Input.is_action_pressed("ui_down"):
			direction.y = 1
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
		if Input.is_action_pressed("ui_right"):
			direction.x = 1
		
		#ajusta y realiza el movimiento
		movement = direction.normalized()
		movement = move_and_slide(movement * speed)

func animations(): #ajusta la apariencia del jugador
	if movement.x or movement.y !=0: #Si se mueve
		$Anim_Sprite.play("Walking")
	else:
		$Anim_Sprite.play("Stay")
	
	if direction.x >= 1: #dirección a la que mira el jugador
		$Sprite.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif direction.x <= -1:
		$Sprite.scale.x = -1
		$CollisionShape2D.scale.x = -1

func _on_Area2D_body_entered(body): #cuando algo entra a la hitbox
		if body.is_in_group("Enemy"): #si entra un enemigo, ajustar dirección del knockback
			if body.global_position.x < self.global_position.x :
				knockback.x = 2000
			elif body.global_position.x > self.global_position.x:
				knockback.x = -2000
			if body.global_position.x < self.global_position.x :
				knockback.y = -2000
			elif body.global_position.x > self.global_position.x:
				knockback.y = 2000
			
			$Sprite/ProgressBar.show() #mostrar salud
			$Sprite/Hide_Timer.start() #cuando se desactiva la salud
			$Visual_anim.play("Hurt") #efecto de daño
			health.current -= 1 #reduce salud
		knockback = knockback.move_toward(Vector2.ZERO,0) #realiza knockback
		knockback = move_and_slide(knockback)
		

func attack(): #función de ataque
	if Input.is_action_pressed("Atacar"): #si se presiona z
		can_walk = false
		$Anim_Sprite.play("Punch")

func _on_Anim_Sprite_animation_finished(anim_name): #cuando se acaba una animación
	if anim_name == "Punch":
		can_walk = true

func _on_Hide_Timer_timeout(): #para esconder la barra de salud
	$Sprite/ProgressBar.hide()
