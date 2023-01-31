extends KinematicBody2D

export (int) var speed = 200 #Velocidad del jugador

var direction = Vector2.ZERO #vector de dirección del jugador
var movement = Vector2() #vector de movimiento del jugador
var knockback = Vector2() #vector de knockback del jugador

var can_walk = true #permite el movimiento, bloqueado en caso de animaciones como golpear
var in_knockback = true

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
		
		#ajusta el Vector del Knocback a uno nulo en caso de no haber sido golpeado
		if in_knockback == false:
			knockback = Vector2.ZERO
		
		#ajusta y realiza el movimiento
		movement = direction.normalized()
		movement = move_and_slide((movement * speed)+knockback)

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
			in_knockback = true #activa el knockback
			
			#ajuste de componentes X e Y del vector del Knocback
			knockback.x = 450 * sin(get_angle_to(body.position))
			knockback.y = 450 * cos(get_angle_to(body.position))
			
			$Knockback_timer.start() #activa el temporizador del knocback
			$Sprite/ProgressBar.show() #mostrar salud
			$Sprite/Hide_Timer.start() #cuando se desactiva la salud
			$Visual_anim.play("Hurt") #efecto de daño
			health.current -= 1 #reduce salud
		

func attack(): #función de ataque
	if Input.is_action_pressed("Atacar"): #si se presiona z
		can_walk = false
		$Anim_Sprite.play("Punch")

func _on_Anim_Sprite_animation_finished(anim_name): #cuando se acaba una animación
	if anim_name == "Punch":
		can_walk = true

func _on_Hide_Timer_timeout(): #para esconder la barra de salud
	$Sprite/ProgressBar.hide()

func _on_Knockback_timer_timeout(): #cuando acaba el temporizador, el jugador deja de recibir el knocback
	in_knockback = false
