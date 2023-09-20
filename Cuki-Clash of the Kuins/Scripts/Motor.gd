extends StaticBody2D

var OFFCOLOR:String = "ffffff"
var ONCOLOR:String = "00ff00"
var OVERHEATEDCOLOR:String = "ff0000"

enum MotorState
{
	ON,
	OFF,
	OVERHEATED
}

var motorState = MotorState.OFF

var state:
	set(new_state):
		#if state == true:
			#$AnimationPlayer.play("On")
		#else:
			#$AnimationPlayer.play("Off")
		state = new_state

func refreshColorState():
	if motorState == MotorState.OFF:
		$StateColor.color = Color(OFFCOLOR)
	if motorState == MotorState.ON:
		$StateColor.color = Color(ONCOLOR)
	if motorState == MotorState.OVERHEATED:
		$StateColor.color = Color(OVERHEATEDCOLOR)

func setMotorState(newMotorState):
	motorState = newMotorState
	if motorState == MotorState.OFF:
		state = false
	if motorState == MotorState.ON:
		state = true
	if motorState == MotorState.OVERHEATED:
		state = false

func _ready():
	refreshColorState()

func _on_area_2d_area_entered(area):
	if area.name == "Tar" && motorState != MotorState.OVERHEATED:
		setMotorState(MotorState.ON)
	if area.name == "Flame":
		setMotorState(MotorState.OVERHEATED)
	if area.name == "Ice" && motorState == MotorState.OVERHEATED:
		setMotorState(MotorState.ON)
	refreshColorState()
