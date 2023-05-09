extends Node



var movementState = "None"
var timedState = "None"

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

func contactWithMovementState(elementalEvent):
	if (movementState == "None"):
		if (elementalEvent == "Tar"):
			movementState = "Tar"
		if (elementalEvent == "Shock"):
			movementState = "Paralyzed"

func getMovementState():
	return movementState

func getTemporalState():
	return timedState
