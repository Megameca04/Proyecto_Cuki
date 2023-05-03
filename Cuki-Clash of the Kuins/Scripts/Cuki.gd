extends CharacterBody2D

@export var speed = 200 #Velocidad del jugador

var direction = Vector2.ZERO #vector de dirección del jugador
var movement = Vector2() #vector de movimiento del jugador
var knockback = Vector2() #vector de knockback del jugador

var can_walk = true #permite el movimiento, bloqueado en caso de animaciones como golpear
var in_knockback = false #establece si se debe aplicar el movimiento de knockback en el jugador
var dashing = false #establece si se debe aplicar el efecto de esquiva en el jugador

@onready var health = $Salud #referencia al nodo de salud
@onready var health_bar = $Health_bar #referencia al nodo de la barra de vida
@onready var hide_timer = $Hide_timer #referencia al nodo que oculta la barra de vida

func _ready(): #se ejecuta apenas el objeto entra al arbol de nodos
	#conecta los nodos de salud y barra de salud para que muestre la vida graficamente
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"game_over"))
	health.initialize()

func _process(delta): #ciclo principal del juego
	if can_walk == true: #si puede caminar(si no está reproduciendo una animación estatica)
		animations() 
	attack() #Siempre ataca


func _physics_process(delta):
	CukiDirections()
	calcularMovimiento()
	moviendose()

func CukiDirections():
	direction = Vector2.ZERO
	if can_walk == true: #si puede caminar
		#recibe la entrada por teclado del jugador
		if Input.is_action_pressed("ui_up"):
			direction.y = -1
		if Input.is_action_pressed("ui_down"):
			direction.y = 1
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
		if Input.is_action_pressed("ui_right"):
			direction.x = 1

func calcularMovimiento():
	movement = Vector2.ZERO
	movement = direction.normalized()
	if dashing:
		movement *= 2

func moviendose():
	set_velocity((movement*speed) + knockback)
	move_and_slide()
	movement = velocity

func animations(): #ajusta la apariencia del jugador
	if movement.x or movement.y !=0: #Si se mueve
		$Anim_Sprite.play("Walking")
	else:
		$Anim_Sprite.play("Stay")
	
	if direction.x >= 1: #dirección a la que mira el jugador
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif direction.x <= -1:
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1

func attack(): #función de ataque
	if Input.is_action_pressed("Atacar"): #si se presiona z
		can_walk = false
		$Anim_Sprite.play("Punch")
	
	if Input.is_action_just_pressed("Dash"): #si se presiona x
		if !dashing:
			dashing = true
			$Dash_timer.start()
	
	$Hitbox/CollisionShape2D.disabled = dashing #deshabilita detección de daño
	set_collision_mask_value(2,!dashing) #deshabilita colisión con enemigos

func game_over():
	self.set_physics_process(false)
	self.set_process(false)

func _on_Hitbox_body_entered(body): #cuando algo entra a la hitbox
		if body.is_in_group("Enemy"): #si entra un enemigo
			in_knockback = true #activa el knockback
			
			#ajuste de componentes X e Y del vector del Knocback
			knockback -= 500*Vector2(cos(get_angle_to(body.position)),sin(get_angle_to(body.position)))
			
			$Knockback_timer.start() #activa el temporizador del knocback
			$Health_bar.show() #mostrar salud
			$Hide_timer.start() #cuando se desactiva la salud
			$Visual_anim.play("Hurt") #efecto de daño
			health.current -= 1 #reduce salud

func _on_Anim_Sprite_animation_finished(anim_name): #cuando se acaba una animación
	if anim_name == "Punch":
		can_walk = true

func _on_Hide_Timer_timeout(): #para esconder la barra de salud
	$Health_bar.hide()

func _on_Dash_timer_timeout(): #cuando acaba el tiempo de dash, se establece a la velocidad normal
	dashing = false

func _on_knockback_timer_timeout():
	in_knockback = false
	knockback = Vector2.ZERO

func _on_hitbox_area_entered(area):
	if area.is_in_group("expl_attack"):
		in_knockback = true
		knockback -= 750*Vector2(cos(get_angle_to(area.position)),sin(get_angle_to(area.position)))
		$Knockback_timer.start() #activa el temporizador del knocback
		$Health_bar.show() #mostrar salud
		$Hide_timer.start() #cuando se desactiva la salud
		$Visual_anim.play("Hurt") #efecto de daño
		health.current -= 1 #reduce salud
	if area.is_in_group("expl_blonk"):
		in_knockback = true
		knockback -= 750*Vector2(cos(get_angle_to(area.position)),sin(get_angle_to(area.position)))
		$Knockback_timer.start()
		$Health_bar.show()
		$Hide_timer.start()
		$Visual_anim.play("Hurt")
		health.current -= 1
	if area.is_in_group("Piedra"):
		in_knockback = true
		print(Vector2(cos(get_angle_to(area.position)),sin(get_angle_to(area.position))))
		knockback = 500*Vector2(cos(get_angle_to(area.position)),sin(get_angle_to(area.position)))
		$Knockback_timer.start()
		$Health_bar.show()
		$Hide_timer.start()
		$Visual_anim.play("Hurt")
		health.current -= 1
