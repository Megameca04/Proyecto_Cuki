extends Node

var movementState = "None"
var timedState = "None"
@onready var elemental_timer = $Elemental_timer

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
	if (movementState == "Tar"):
		movementState = "None"
	if (timedState == "Venom" || "Fire"):
		timedState = "None"

func contactWithTemporalState(elementalEvent):
	if (timedState == "None"):
		if (elementalEvent == "Poison"):
			timedState = "Venom"
		if (elementalEvent == "Flame"):
			timedState == "Fire"
		if (elementalEvent == "Freeze"):
			timedState = "Ice"
		elemental_timer.start()

func contactWithMovementState(elementalEvent):
	if (movementState == "None"):
		if (elementalEvent == "Tar"):
			movementState = "Tar"
		if (elementalEvent == "Shock"):
			movementState = "Paralyzed"
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
