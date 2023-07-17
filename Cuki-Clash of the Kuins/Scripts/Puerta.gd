extends StaticBody2D

@export var colorhex:String = ""

var state = false:
	set(new_state):
			if state == true:
				$AnimationPlayer.play("Cierra")
			else:
				$AnimationPlayer.play("Abre")
			state = new_state

var palancas:int = 0

func _ready():
	for i in get_tree().get_nodes_in_group("Palanca"):
		if i.colorhex == self.colorhex:
			palancas +=1
	$ColorRect.color = Color(colorhex)

func _process(delta):
	var palancas_activas:int = 0
	for i in get_tree().get_nodes_in_group("Palanca"):
		if i.colorhex == self.colorhex and i.state == true:
			palancas_activas += 1
	
	if palancas == palancas_activas and palancas != 0:
		if state != true:
			state = true
	else:
		if state != false:
			state = false
	
	$CollisionShape2D.disabled = state
	$ColorRect.visible = !state
