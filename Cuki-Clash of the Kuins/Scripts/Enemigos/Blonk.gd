extends CharacterBody2D

enum BlonkState {
		PATROL,
		ATTACKING,
		RESTING
	}

const ATTACK = preload("res://Entidades/Elementos combates/Explosion.tscn")

@export var blonkSpeed = 50

var Cuki = null
var CukiOnAttackRange = null
var state = BlonkState.PATROL
var movement = Vector2()

@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var pause_attack_timer = $Pause_attack_timer
@onready var elemental_state = $ElementalState 

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(_delta):
	animationFace()
	blonkBehaviour()

func _physics_process(_delta):
	blonkMovement()

func blonkMovement():
	if (
			elemental_state.getState() != 2 and elemental_state.getState() != 9
			and elemental_state.getState() != 6
		):
		
		movement = Vector2.ZERO
		
		if Cuki != null && state == BlonkState.PATROL:
			movement = position.direction_to(Cuki.position)
		else:
			movement = Vector2.ZERO
		
		if elemental_state.getState() == 4:
			set_velocity(movement * blonkSpeed / 2)
		else:
			set_velocity(movement * blonkSpeed)
		
		movement = velocity
		move_and_slide()

func blonkBehaviour():
	
	if elemental_state.getState() != 2 and elemental_state.getState() != 9:
		
		if CukiOnAttackRange != null and state == BlonkState.PATROL:
			stateAndAnimationChange(BlonkState.ATTACKING)

func animationFace():
	
	if movement.x <= 1:
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1
	elif movement.x >= -1:
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1

func stateAndAnimationChange(blonkState):
	state = blonkState
	
	match blonkState:
		BlonkState.PATROL:
			$AnimationPlayer.play("Moving")
		BlonkState.ATTACKING:
			$AnimationPlayer.play("Attacking")
		BlonkState.RESTING:
			$AnimationPlayer.play("Moving")

func attackPlayer():
	if elemental_state.getState() != 2 && elemental_state.getState() != 9:
		
		var atk = ATTACK.instantiate()
		
		atk.add_to_group("expl_blonk")
		atk.global_position = global_position
		call_deferred("add_sibling",atk)
		stateAndAnimationChange(BlonkState.RESTING)
		pause_attack_timer.start()

func defeat():
	self.queue_free()

func elemental_damage(element):
	elemental_state.contactWithElement(element)

func attackedBySomething(knockbackForce, healthLost, something):
	health.current -= healthLost
	if elemental_state.getState() != 9:
		health_bar.show()
		hide_timer.start()
		if elemental_state.getState() == 5:
			health.current -= healthLost * 2
		else:
			health.current -= healthLost

func _on_vision_field_body_entered(body):
	if body != self:
		if body.get_name() == "Cuki":
			Cuki = body

func _on_vision_field_body_exited(body):
	if body.get_name() == "Cuki":
		Cuki = null

func _on_hitbox_area_entered(area):
	
	if area.is_in_group("C_attack"):
		attackedBySomething(0,1,null)
	
	if (
			(area.is_in_group("expl_attack") or area.is_in_group("expl_bun"))
			and !area.is_in_group("expl_blonk")
		):
		
		attackedBySomething(0,2,null)
		
		elemental_state.contactWithElement(area.element)
	
	if (area.name == "Water" && elemental_state.getState() == 2):
		attackedBySomething(0,1,null)

func _on_attack_area_body_entered(body):
	if body != self:
		if body.get_name() == "Cuki":
			CukiOnAttackRange = body

func _on_attack_area_body_exited(body):
	if body.get_name() == "Cuki":
		CukiOnAttackRange = null

func _on_hide_timer_timeout():
	health_bar.hide()

func _on_pause_attack_timer_timeout():
	stateAndAnimationChange(BlonkState.PATROL)

func _on_elemental_state_temporal_damage():
	if (elemental_state.getState() == 1):
		attackedBySomething(0,1,null)
	if (elemental_state.getState() == 7):
		attackedBySomething(0,2,null)
	if (elemental_state.getState() == 8):
		attackedBySomething(0,1,null)
