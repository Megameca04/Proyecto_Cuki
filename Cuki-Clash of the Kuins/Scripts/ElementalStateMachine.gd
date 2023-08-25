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

func contactWithElementGroup(elementalGroup):
	for i in range(0, elementalGroup.size()):
		if (elementalGroup[i] == "Water"):
			contactWithWater()
		if (elementalGroup[i] == "Poison" || elementalGroup[i] == "Flame" || elementalGroup[i] == "Freeze"):
			contactWithTemporalState(elementalGroup[i])
		if (elementalGroup[i] == "Tar" || elementalGroup[i] == "Shock"):
			contactWithMovementState(elementalGroup[i])

func contactWithWater():
	if (timedState == "Ice" && movementState != "Paralyzed" && movementState != "Tar"):
		timedState = "None"
		movementState = "Frozen"
		elemental_timer.set_wait_time(elemental_timer_time)
		elemental_timer.start()
		return
	if (movementState == "Tar"):
		movementState = "None"
		return
	if (timedState == "Venom" || timedState == "Fire" || timedState == "IntenseFire"):
		timedState = "None"
		return
	if (timedState == "None"):
		timedState = "Wet"
		elemental_timer.set_wait_time(elemental_timer_time)
		elemental_timer.start()
	if (movementState == "Paralyzed"):
		timedState = "Electroshocked"
		elemental_damage.start()
		elemental_timer.set_wait_time(elemental_timer_time)
		elemental_timer.start()

func contactWithTemporalState(elementalEvent):
	if (timedState == "None"):
		if (elementalEvent == "Poison" && timedState != "Wet"):
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
	if (timedState == "Wet" && elementalEvent == "Freeze"):
		timedState = "Frozen"
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
			if (timedState == "Wet"):
				timedState = "Electroshocked"
				elemental_damage.start()
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
