extends CharacterBody2D

@export var speed = 200 #Velocidad del jugador
var totalSpeed = 0

var direction = Vector2.ZERO #vector de dirección del jugador
var movement = Vector2() #vector de movimiento del jugador
var knockback = Vector2() #vector de knockback del jugador

var can_walk = true #permite el movimiento, bloqueado en caso de animaciones como golpear
var in_knockback = false #establece si se debe aplicar el movimiento de knockback en el jugador
var dashing = false #establece si se debe aplicar el efecto de esquiva en el jugador

@onready var health = $Salud #referencia al nodo de salud
@onready var health_bar = $Health_bar #referencia al nodo de la barra de vida
@onready var hide_timer = $Hide_timer #referencia al nodo que oculta la barra de vida
@onready var elemental_state = $ElementalState # Referencia a la barra de estado de los elementos

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
	if can_walk == true && elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen": #si puede caminar
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
	if elemental_state.getMovementState() != "Tar":
		movement = Vector2.ZERO
		movement = direction.normalized()
		if dashing:
			movement *= 2
		if elemental_state.getTemporalState() == "Ice":
			totalSpeed = speed / 2
		else:
			totalSpeed = speed

func moviendose():
	if elemental_state.getMovementState() != "Tar":
		set_velocity((movement*totalSpeed) + knockback)
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
	if elemental_state.getMovementState() != "Paralyzed":
		if Input.is_action_pressed("Atacar"): #si se presiona z
			can_walk = false
			$Anim_Sprite.play("Punch")
	
		if Input.is_action_just_pressed("Dash"): #si se presiona x
			if !dashing:
				dashing = true
				$Dash_timer.start()
	
		$Hitbox/CollisionShape2D.disabled = dashing #deshabilita detección de daño
		set_collision_mask_value(2,!dashing) #deshabilita colisión con enemigos

func attackedBySomething(knockbackForce, healthLost, something):
	if elemental_state.getMovementState() != "Frozen":
		in_knockback = true #activa el knockback
		#ajuste de componentes X e Y del vector del Knocback
		knockback -= knockbackForce*Vector2(cos(get_angle_to(something.position)),sin(get_angle_to(something.position)))
		$Knockback_timer.start() #activa el temporizador del knocback
		$Health_bar.show() #mostrar salud
		$Hide_timer.start() #cuando se desactiva la salud
		$Visual_anim.play("Hurt") #efecto de daño
		if elemental_state.getTemporalState() != "Venom":
			health.current -= healthLost #reduce salud
		else:
			health.current -= healthLost * 2

func game_over():
	self.set_physics_process(false)
	self.set_process(false)

func _on_Hitbox_body_entered(body): #cuando algo entra a la hitbox
		if body.is_in_group("Enemy"): #si entra un enemigo
			attackedBySomething(500, 1, body)

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
		attackedBySomething(750, 1, area)
	if area.is_in_group("expl_blonk"):
		attackedBySomething(750, 1, area)
	if area.is_in_group("Piedra"):
		attackedBySomething(500, 1, area)
	if area.is_in_group("Elements"):
		elemental_state.contactWithElement(area.name)
		if (area.name == "Water" && elemental_state.getMovementState() == "Paralyzed"):
			attackedBySomething(0, 1, area)
		area.queue_free()

