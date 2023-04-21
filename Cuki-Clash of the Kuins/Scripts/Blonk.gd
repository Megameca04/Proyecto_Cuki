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
@export var blonkSpeed = 50

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(delta):
	animationFace()
	blonkBehaviour()

func _physics_process(delta):
	blonkMovement()

func blonkMovement():
	movement = Vector2.ZERO
	if Cuki != null && state == BlonkState.Patrol:
		movement = position.direction_to(Cuki.position)
	else:
		movement = Vector2.ZERO
	set_velocity(movement * blonkSpeed)
	move_and_slide()
	movement = velocity

func blonkBehaviour():
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
	var atk = ATTACK.instantiate()
	atk.add_to_group("expl_blonk")
	atk.global_position = attack_spawner.global_position
	call_deferred("add_sibling",atk)
	stateAndAnimationChange(BlonkState.Resting)
	pause_attack_timer.start()

func defeat():
	self.queue_free()

func _on_vision_field_body_entered(body):
	if body != self:
		if body.get_name() == "Cuki":
			Cuki = body

func _on_vision_field_body_exited(body):
	if body.get_name() == "Cuki":
		Cuki = null

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		health_bar.show()
		hide_timer.start()
		health.current -= 1
	if area.is_in_group("expl_attack"):
		health_bar.show()
		hide_timer.start()
		health.current -= 2

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
