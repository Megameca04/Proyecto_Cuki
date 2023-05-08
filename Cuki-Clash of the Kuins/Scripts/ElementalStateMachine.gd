extends Node

enum MovementState { None, Frozen, Tar, Paralyzed } # CHANGE THE ENUMS TO A STRING (HOLLOW)
enum TimedState { None, Venom, Fire, Ice }
enum ElementalEvent { Cured, Wet, Poisoned, Dirty, Torched, Freezed, Shocked }

var movementState = MovementState.None
var timedState = TimedState.None

func _ready():
	pass

func _process(delta):
	pass

func contactWithElement(elementalEvent):
	if (elementalEvent == ElementalEvent.Wet):
		contactWithWater()
	if (elementalEvent == ElementalEvent.Poisoned || elementalEvent == ElementalEvent.Torched || elementalEvent == ElementalEvent.Freezed):
		contactWithTemporalState(elementalEvent)
	if (elementalEvent == ElementalEvent.Dirty || elementalEvent == ElementalEvent.Shocked):
		contactWithMovementState(elementalEvent)

func contactWithWater():
	if (timedState == TimedState.Ice && movementState != MovementState.Paralyzed && movementState != MovementState.Tar):
		timedState = TimedState.None
		movementState = MovementState.Frozen
	if (movementState == MovementState.Tar):
		movementState = MovementState.None
	if (timedState == TimedState.Venom || timedState.Fire):
		timedState = TimedState.None

func contactWithTemporalState(elementalEvent):
	if (timedState == TimedState.None):
		if (elementalEvent == ElementalEvent.Poisoned):
			timedState = TimedState.Venom
		if (elementalEvent == ElementalEvent.Torched):
			timedState == TimedState.Fire
		if (elementalEvent == ElementalEvent.Freezed):
			timedState = TimedState.Ice

func contactWithMovementState(elementalEvent):
	if (movementState == MovementState.None):
		if (elementalEvent == ElementalEvent.Dirty):
			movementState = MovementState.Tar
		if (elementalEvent == ElementalEvent.Shocked):
			movementState = MovementState.Paralyzed

func getMovementState():
	return movementState

func getTemporalState():
	return timedState
