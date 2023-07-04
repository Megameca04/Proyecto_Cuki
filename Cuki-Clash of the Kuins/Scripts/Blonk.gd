extends CharacterBody2D

enum BlonkState { Patrol, Attacking, Resting }
var Cuki = null
var CukiOnAttackRange = null
var state = BlonkState.Patrol
var movement = Vector2()
const ATTACK = preload("res://Entidades/Explosion.tscn")
@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var pause_attack_timer = $Pause_attack_timer
@onready var attack_spawner = $AttackSpawner
@onready var elemental_state = $ElementalState # Referencia a la barra de estado de los elementos
@export var blonkSpeed = 50

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(delta):
	animationFace()
	blonkBehaviour()
	$Label.text = "TS: "+elemental_state.getTemporalState()+"\nMS: "+elemental_state.getMovementState()+"\nTl: "+str(elemental_state.elemental_timer.get_time_left())

func _physics_process(delta):
	blonkMovement()

func blonkMovement():
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen" && elemental_state.getMovementState() != "Tar":
		movement = Vector2.ZERO
		if Cuki != null && state == BlonkState.Patrol:
			movement = position.direction_to(Cuki.position)
		else:
			movement = Vector2.ZERO
		if (elemental_state.getMovementState() == "Ice"):
			set_velocity(movement * blonkSpeed / 2)
		else:
			set_velocity(movement * blonkSpeed)
		move_and_slide()
		movement = velocity

func blonkBehaviour():
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":
		if CukiOnAttackRange != null && state == BlonkState.Patrol:
			stateAndAnimationChange(BlonkState.Attacking)

func animationFace():
	if movement.x <= 1:
		$Sprite2D.scale.x = -1
		$CollisionShape2D.scale.x = -1
	elif movement.x >= -1:
		$Sprite2D.scale.x = 1
		$CollisionShape2D.scale.x = 1

func stateAndAnimationChange(blonkState):
	state = blonkState
	if blonkState == BlonkState.Patrol:
		$AnimationPlayer.play("Moving")
	elif blonkState == BlonkState.Attacking:
		$AnimationPlayer.play("Attacking")
	elif blonkState == BlonkState.Resting:
		$AnimationPlayer.play("Moving")

func attackPlayer():
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":
		var atk = ATTACK.instantiate()
		atk.add_to_group("expl_blonk")
		atk.global_position = attack_spawner.global_position
		call_deferred("add_sibling",atk)
		stateAndAnimationChange(BlonkState.Resting)
		pause_attack_timer.start()

func defeat():
	self.queue_free()

func attackedBySomething(healthLost):
	if elemental_state.getMovementState() != "Frozen":
		health_bar.show()
		hide_timer.start()
		if elemental_state.getTemporalState() == "Venom":
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
		attackedBySomething(1)
	if area.is_in_group("expl_attack") || area.is_in_group("expl_bun"):
		attackedBySomething(2)
		elemental_state.contactWithElement(area.name)
		if (area.name == "Water" && elemental_state.getMovementState() == "Paralyzed"):
			attackedBySomething(1)

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
	stateAndAnimationChange(BlonkState.Patrol)

func _on_elemental_state_temporal_damage():
	if (elemental_state.getTemporalState() == "Fire"):
		health.current -= 1 
		health_bar.show()
		hide_timer.start()
	if (elemental_state.getTemporalState() == "IntenseFire"):
		health.current -= 1 * 2
		health_bar.show()
		hide_timer.start()
