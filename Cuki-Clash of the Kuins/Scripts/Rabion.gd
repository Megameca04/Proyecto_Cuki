extends KinematicBody2D

var Cuki = null
var boom = Vector2()
var velocity = Vector2()
export (float) var acceleration = 0.20

export (float) var mass = 400

var speed = mass * acceleration

func _process(delta):
	animations()

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	boom = boom.move_toward(Vector2.ZERO,200)
	boom = move_and_slide(boom)
	
	if Cuki != null:
		velocity = position.direction_to(Cuki.position) * speed
	else:
		velocity = Vector2.ZERO
	
	velocity = move_and_slide(velocity)
	

func _on_VisionField_body_entered(body):
	if body != self:
		if body.get_name() == "Cuki":
			Cuki = body

func _on_VisionField_body_exited(body):
	Cuki = null

func animations():
	if velocity.x or velocity.y !=0:
		$AnimationPlayer.play("Movin")
	else:
		$AnimationPlayer.play("Stay")
	if velocity.x <= 1:
		$Sprite.scale.x = 1
		$CollisionShape2D.scale.x = 1
	elif velocity.x >= -1:
		$Sprite.scale.x = -1
		$CollisionShape2D.scale.x = -1



func _on_Area2D_area_entered(area):
	if area.name == "Bat_zone":
		
		if area.global_position.x < self.global_position.x :
			boom.x = 1250
		elif area.global_position.x > self.global_position.x:
			boom.x = -1250
		
		if area.global_position.y < self.global_position.y :
			boom.y = 1250
		elif area.global_position.y > self.global_position.y:
			boom.y = -1250
