extends Node

var movementState = "None"
var timedState = "None"
@onready var elemental_timer = $Elemental_timer
@onready var elemental_damage = $Elemental_damage
signal temporal_damage
@export var elemental_timer_time:float
@export var elemental_damage_time:float

func contactWithElement(elementalEvent):
	if (elementalEvent == "Water"):
		contactWithWater()
	if (elementalEvent == "Poison" || elementalEvent == "Flame" || elementalEvent == "Freeze"):
		contactWithTemporalState(elementalEvent)
	if (elementalEvent == "Tar" || elementalEvent == "Shock"):
		contactWithMovementState(elementalEvent)

func contactWithWater():
	if (timedState == "Ice" && movementState != "Paralyzed" && movementState != "Tar"):
		timedState = "None"
		movementState = "Frozen"
		elemental_timer.set_wait_time(elemental_timer_time)
		elemental_timer.start()
	if (movementState == "Tar"):
		movementState = "None"
	if (timedState == "Venom" || timedState == "Fire" || timedState == "IntenseFire"):
		timedState = "None"
		elemental_timer.stop()

func contactWithTemporalState(elementalEvent):
	if (timedState == "None"):
		if (elementalEvent == "Poison"):
			timedState = "Venom"
		if (elementalEvent == "Flame"):
			timedState = "Fire"
			elemental_damage.start()
			if (movementState == "Tar"):
				movementState = "None"
				timedState = "IntenseFire"
				elemental_timer.set_wait_time(elemental_timer.get_wait_time() - elemental_timer_time / 2)
				return
		if (elementalEvent == "Freeze"):
			timedState = "Ice"
		elemental_timer.set_wait_time(elemental_timer_time)
		elemental_timer.start()

func contactWithMovementState(elementalEvent):
	if (movementState == "None"):
		if (elementalEvent == "Tar"):
			if (timedState == "Fire"):
				movementState = "None"
				timedState = "IntenseFire"
				elemental_timer.set_wait_time(elemental_timer.get_wait_time() - elemental_timer_time / 2)
				return
			else:
				movementState = "Tar"
		if (elementalEvent == "Shock"):
			movementState = "Paralyzed"
		elemental_timer.set_wait_time(elemental_timer_time)
		elemental_timer.start()

func cureEverything():
	movementState = "None"
	timedState = "None"

func getMovementState():
	return movementState

func getTemporalState():
	return timedState

func _on_elemental_timer_timeout():
	cureEverything()

func _on_elemental_damage_timeout():
	emit_signal("temporal_damage")
	elemental_damage.set_wait_time(elemental_damage_time)
	elemental_damage.start()
