extends CharacterBody2D

const GROUND_SLAM = preload("res://Entidades/Elementos combates/Explosion.tscn")

@export var speed : float = 200

@export var phone_charge : int :
	set(v):
		phone_charge = clamp(v,0,2)
	get:
		return phone_charge

var next_an : int = 0

var charge : float = 0:
	set(v):
		charge = clamp(v,0,1)

var total_speed : float = 0
var can_charge : bool = false

var direction := Vector2.ZERO :
	set(v):
		direction = v.normalized()
		
		if v != Vector2.ZERO:
			attack_node.rotation = v.angle()

var movement := Vector2()
var knockback := Vector2()

@onready var health = $Salud
@onready var anim_node = $Animaciones
@onready var sprite = $CukiSprite
@onready var hitbox_col = $Hitbox/CollisionShape2D
@onready var colision_s = $CollisionShape2D
@onready var attack_node = $Attack_node
@onready var elemental_state = $ElementalState
@onready var maq_estados = $MaquinaEstados

func _ready():
	health.connect("depleted",Callable(self,"game_over"))
	health.initialize()


func _process(_delta):
	$Label.text = $MaquinaEstados.estado_actual.name

func attacked_by_something(knockbackForce, healthLost, something):
	
	maq_estados.cambiar_estado("JugadorHerido")
	
	if something != null:
		knockback -= knockbackForce*Vector2(
				cos(get_angle_to(something.position)),
				sin(get_angle_to(something.position))
		)
	
	if elemental_state.getState() == 5:
		health.current -= healthLost*2
	else:
		health.current -= healthLost

func _on_Hitbox_body_entered(body):
	
	if body.is_in_group("Enemy"):
		
		attack_node.rotation = attack_node.global_position.angle_to(body.global_position)
		attacked_by_something(200, 1, body)

func _on_Anim_Sprite_animation_finished(anim_name):
	
	match anim_name:
		
		"Hit_1":
			next_an = 1
			if can_charge:
				maq_estados.cambiar_estado("JugadorCharging")
			else:
				maq_estados.cambiar_estado("JugadorIdle")
		
		"Hit_2":
			next_an = 0
			if can_charge:
				maq_estados.cambiar_estado("JugadorCharging")
			else:
				maq_estados.cambiar_estado("JugadorIdle")
		
		"Dash":
			maq_estados.cambiar_estado("JugadorMovim")
		
		"Spin_attack":
			maq_estados.cambiar_estado("JugadorIdle")
		
		"Hurt":
			maq_estados.cambiar_estado("JugadorIdle")
		
		"ChargingAttack":
			if charge == 1:
				maq_estados.cambiar_estado("JugadorAtaqueP")
			else:
				maq_estados.cambiar_estado("JugadorIdle")
		
		"ChargedAttack":
			maq_estados.cambiar_estado("JugadorIdle")

func _on_hitbox_area_entered(area):
	
	if area.is_in_group("expl_attack"):
		attacked_by_something(750, 1, area)
		elemental_state.contactWithElement(area.element)
		
		if area.element == 4 and elemental_state.getState() == 2:
			attacked_by_something(0, 3, area)
	
	if area.is_in_group("expl_blonk"):
		attacked_by_something(750, 3, area)
	
	if area.is_in_group("Piedra"):
		attacked_by_something(500, 1, area)
		elemental_state.contactWithElement(area.element)
		elemental_state.contactWithElementGroup(area.get_groups())
	
	if area.is_in_group("item_ayuda"):
		match area.tipo:
			0:
				health.current += 1
			1:
				phone_charge += 1

func _on_elemental_state_temporal_damage():
	
	if (elemental_state.getState() == 1):
		attacked_by_something(0, 1, null)
	
	if (elemental_state.getState() == 7):
		attacked_by_something(0, 2, null)
	
	if (elemental_state.getState() == 8):
		attacked_by_something(0, 1, null)

func _on_salud_depleted():
	self.set_physics_process(false)
	self.set_process(false)
