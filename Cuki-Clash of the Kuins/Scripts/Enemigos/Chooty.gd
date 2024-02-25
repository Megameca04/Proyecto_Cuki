extends CharacterBody2D

enum ChootyState {
	PATROL,
	RUNNING,
	SHOOTING,
	RESTING
	}

enum Elements {
	NONE,			#0
	FIRE,			#1
	SHOCK,			#2
	WATER,			#3
	ICE, 			#4
	POISON, 		#5
	TAR				#6
}

const PROJECTILES = {
	"S" : preload("res://Entidades/Enemigos/Proyectiles Chooty/Piedra.tscn"),
	"B" : preload("res://Entidades/Enemigos/Proyectiles Chooty/BurbujaTar.tscn"),
	"D" : preload("res://Entidades/Enemigos/Proyectiles Chooty/DardoVeneno.tscn")
}

@export var element : Elements

var Cuki = null

var Cuki_on_shoot_range = false
var state = ChootyState.PATROL

var speed = 100
var movement = Vector2.ZERO
var knockback = Vector2.ZERO
var scape_position = Vector2.ZERO

@onready var shoot_timer = $Shoot_timer
@onready var vision_raycast = $Vision_Raycast
@onready var health = $Salud
@onready var health_bar = $ProgressBar
@onready var hide_timer = $Hide_timer
@onready var elemental_state = $ElementalState

func _ready():
	health.connect("changed",Callable(health_bar,"set_value"))
	health.connect("max_changed",Callable(health_bar,"set_max"))
	health.connect("depleted",Callable(self,"defeat"))
	health.initialize()

func _process(_delta):
	chootyBehaviour()
	if Cuki != null:
		$Label.text = str(global_position.distance_to(Cuki.global_position))+"\n"+str(state)

func _physics_process(_delta):
	chootyMovement()

func chootyMovement():
	
	movement = Vector2.ZERO
	
	if scape_position != Vector2.ZERO:
		
		if state != ChootyState.RESTING:
			
			if vision_raycast.is_colliding():
				
				var distance_runned = abs(global_position.distance_to(scape_position)-100)
				var new_sp = to_global(-global_position.direction_to(scape_position).orthogonal().normalized() * distance_runned)
				scape_position = new_sp
				vision_raycast.target_position = to_local(scape_position)
			
			if global_position.distance_to(scape_position) > 5:
				movement = (global_position.direction_to(scape_position))
			else:
				scape_position = Vector2.ZERO
			
			velocity = (movement + knockback ).normalized()*speed
	
	else:
		if Cuki != null:
			if state != ChootyState.RESTING:
				if global_position.distance_to(Cuki.global_position) < 80 && scape_position == Vector2.ZERO:
					scape_position = to_global(-position.direction_to(Cuki.position)*100)
					vision_raycast.target_position = to_local(scape_position)
	
	move_and_slide()

func chootyBehaviour():
	
	if Cuki != null:
		
		if state != ChootyState.RESTING:
			
			if position.distance_to(Cuki.position) > 80 :
				
				if (
						state != ChootyState.SHOOTING and
						(state == ChootyState.RUNNING or state == ChootyState.PATROL)
					):
					stateAndAnimationChange(ChootyState.SHOOTING)
			else:
				if state != ChootyState.RESTING:
					stateAndAnimationChange(ChootyState.RUNNING)
	else:
		if state != ChootyState.RESTING:
			stateAndAnimationChange(ChootyState.PATROL)

func stateAndAnimationChange(chootyState):
	state = chootyState
	
	match chootyState:
		ChootyState.PATROL:
			$AnimationPlayer.play("Default")
		ChootyState.RUNNING:
			$AnimationPlayer.play("Default")
		ChootyState.SHOOTING:
			$AnimationPlayer.play("Shoot")
		ChootyState.RESTING:
			$AnimationPlayer.play("Default")

func shoot_stone():
	
	if elemental_state.getState() != 3 && elemental_state.getState() != 4:
		
		match element:
			2:
				shock_stone()
			4:
				ice_stones()
			6:
				tar_bubble()
			5:
				shoot_dart()
			_:
				normal_stone()

func normal_stone():
	var stone = PROJECTILES["S"].instantiate()
	
	stone.global_position = global_position
	
	if Cuki != null:
		stone.objective_position = Cuki.global_position
		call_deferred("add_sibling",stone)
		stone.element = element

func ice_stones():
	
	var rocks = 0
	
	while (rocks < 3):
		
		var stone = PROJECTILES["S"].instantiate()
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
			stone.element = element
			rocks += 1

func tar_bubble():
	var bubble = PROJECTILES["B"].instantiate()
	
	bubble.global_position = global_position
	
	if Cuki != null:
		bubble.objective_position = Cuki.global_position
		call_deferred("add_sibling",bubble)
		bubble.element = element

func shock_stone():
	var stone = PROJECTILES["S"].instantiate()
	
	stone.global_position = global_position
	
	if Cuki != null:
		stone.Cuki = Cuki
		call_deferred("add_sibling",stone)
		stone.element = element

func shoot_dart():
	
	if Cuki != null:
		
		var dart = PROJECTILES["D"].instantiate()
		
		dart.objective = Cuki.global_position
		call_deferred("add_child", dart)

func defeat():
	self.queue_free()

func elemental_damage(element):
	elemental_state.contactWithElement(element)

func attackedBySomething(healthLost, something, knockbackForce):
	if elemental_state.getState() != 4:
		
		health_bar.show()
		hide_timer.start()
		knockback =  -knockbackForce*Vector2(cos(get_angle_to(something.global_position)),sin(get_angle_to(something.global_position)))
		
		if elemental_state.getState() == 5:
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
	stateAndAnimationChange(ChootyState.PATROL)

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Shoot":
			stateAndAnimationChange(ChootyState.RESTING)
			shoot_timer.start()

func _on_hitbox_area_entered(area):
	
	if area.is_in_group("C_attack"):
		attackedBySomething(1,area,100)
	
	if area.is_in_group("expl_attack") or area.is_in_group("expl_bun"):
		attackedBySomething(3,area,300)
	
	if !area.is_in_group("Piedra"):
		elemental_state.contactWithElementGroup(area.get_groups())
	
	if (area.name == "Water" && elemental_state.getState() == 2):
		attackedBySomething(1,area,100)

func _on_elemental_state_temporal_damage():
	if elemental_state.getState() == 1:
		attackedBySomething(1,Vector2.ZERO,0)
	if elemental_state.getTemporalState() == 8:
		attackedBySomething(2,Vector2.ZERO,0)
	if elemental_state.getTemporalState() == 9:
		attackedBySomething(1,Vector2.ZERO,0)
