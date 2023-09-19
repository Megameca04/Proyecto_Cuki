extends CharacterBody2D

enum ChootyState {Patrol, Running, Shooting, Resting}

const STONE = preload("res://Entidades/Piedra.tscn")
const BUBBLE = preload("res://Entidades/Burbuja_tar.tscn")
const DART = preload("res://Entidades/Dardo_veneno.tscn")

var Cuki = null

var Cuki_on_shoot_range = false
var state = ChootyState.Patrol

@onready var shoot_timer = $Shoot_timer
@onready var vision_raycast = $Vision_Raycast

@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var elemental_state = $ElementalState # Referencia a la barra de estado de los elementos

var speed = 100
var movement = Vector2.ZERO
var knockback = Vector2.ZERO
var scape_position = Vector2.ZERO

@export var element_attack_name = ""

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(delta):
	chootyBehaviour()
	$Label.text = str(state)

func _physics_process(delta):
	chootyMovement()

func chootyMovement():
	movement = Vector2.ZERO
	
	if scape_position != Vector2.ZERO:
		
		if state != ChootyState.Resting:
			if vision_raycast.is_colliding():
				var distance_runned = abs(global_position.distance_to(scape_position)-50)
				var new_sp = to_global(-global_position.direction_to(scape_position).orthogonal().normalized() * distance_runned)
				scape_position = new_sp
				vision_raycast.target_position = to_local(scape_position)
			
			if global_position.distance_to(scape_position) >= 10:
				movement = (global_position.direction_to(scape_position))*speed
			else:
				scape_position = Vector2.ZERO
			
			velocity = movement
	else:
		if Cuki != null:
				if global_position.distance_to(Cuki.global_position) < 100 && scape_position == Vector2.ZERO && state != ChootyState.Resting:
					scape_position = to_global(-position.direction_to(Cuki.position)*100)
					vision_raycast.target_position = to_local(scape_position)
				
	move_and_slide()


func chootyBehaviour():
	if Cuki != null:
		if state != ChootyState.Resting:
			if position.distance_to(Cuki.position) > 100 :
				if state != ChootyState.Shooting and state != ChootyState.Running:
					stateAndAnimationChange(ChootyState.Shooting)
			else:
				if state != ChootyState.Resting:
					stateAndAnimationChange(ChootyState.Running)
	else:
		if state != ChootyState.Resting:
			stateAndAnimationChange(ChootyState.Patrol)

func stateAndAnimationChange(chootyState):
	state = chootyState
	
	match chootyState:
		ChootyState.Patrol:
			$AnimationPlayer.play("Default")
		ChootyState.Running:
			$AnimationPlayer.play("Default")
		ChootyState.Shooting:
			$AnimationPlayer.play("Shoot")
		ChootyState.Resting:
			$AnimationPlayer.play("Default")

func shoot_stone():
	if elemental_state.getMovementState() != "Paralyzed" && elemental_state.getMovementState() != "Frozen":
		match element_attack_name:
			"Shock":
				shock_stone()
			"Freeze":
				ice_stones()
			"Tar":
				tar_bubble()
			"Poison":
				shoot_dart()
			_:
				normal_stone()

func normal_stone():
	var stone = STONE.instantiate()
	stone.global_position = global_position
	if Cuki != null:
		stone.objective_position = Cuki.global_position
		call_deferred("add_sibling",stone)
		stone.element = element_attack_name

func ice_stones():
	var rocks = 0
	while (rocks < 3):
		var stone = STONE.instantiate()
		var ang = 0
		stone.global_position = global_position
		if Cuki != null:
			match rocks:
				0:
					ang = stone.global_position.direction_to(Cuki.global_position).angle() + PI/12
					stone.objective_position = to_global(Vector2(cos(ang),sin(ang))*stone.global_position.distance_to(Cuki.global_position))
				1:
					ang = stone.global_position.direction_to(Cuki.global_position).angle() 
					stone.objective_position = to_global(Vector2(cos(ang),sin(ang))*stone.global_position.distance_to(Cuki.global_position))
				2:
					ang = stone.global_position.direction_to(Cuki.global_position).angle() - PI/12
					stone.objective_position = to_global(Vector2(cos(ang),sin(ang))*stone.global_position.distance_to(Cuki.global_position))
			call_deferred("add_sibling",stone)
			stone.element = element_attack_name
			rocks += 1

func tar_bubble():
	var bubble = BUBBLE.instantiate()
	bubble.global_position = global_position
	if Cuki != null:
		bubble.objective_position = Cuki.global_position
		call_deferred("add_sibling",bubble)
		bubble.element = element_attack_name
	

func shock_stone():
	var stone = STONE.instantiate()
	stone.global_position = global_position
	if Cuki != null:
		stone.Cuki = Cuki
		call_deferred("add_sibling",stone)
		stone.element = element_attack_name

func shoot_dart():
	if Cuki != null:
		var dart = DART.instantiate()
		dart.objective = Cuki.global_position
		call_deferred("add_child", dart)
	

func defeat():
	self.queue_free()

func elemental_damage(element):
	elemental_state.contactWithElement(element)

func attackedBySomething(healthLost):
	if elemental_state.getMovementState() != "Frozen":
		health_bar.show()
		hide_timer.start()
		if elemental_state.getTemporalState() == "Venom":
			health.current -= healthLost * 2
		else:
			health.current -= healthLost

func _on_vision_field_body_entered(body):
	if body.get_name() == "Cuki":
			Cuki = body

func _on_vision_field_body_exited(body):
	if body.get_name() == "Cuki":
		Cuki = null

func _on_shoot_timer_timeout():
	stateAndAnimationChange(ChootyState.Patrol)

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Shoot":
			stateAndAnimationChange(ChootyState.Resting)
			shoot_timer.start()

func _on_hitbox_area_entered(area):
	if area.is_in_group("C_attack"):
		attackedBySomething(1)
	if area.is_in_group("expl_attack") || area.is_in_group("expl_bun"):
		attackedBySomething(3)
	if !area.is_in_group("Piedra"):
		elemental_state.contactWithElementGroup(area.get_groups())
	if (area.name == "Water" && elemental_state.getMovementState() == "Paralyzed"):
		attackedBySomething(1)

func _on_elemental_state_temporal_damage():
	if (elemental_state.getTemporalState() == "Fire"):
		attackedBySomething(1)
	if (elemental_state.getTemporalState() == "IntenseFire"):
		attackedBySomething(1 * 2)
	if (elemental_state.getTemporalState() == "Electroshocked"):
		attackedBySomething(1)
