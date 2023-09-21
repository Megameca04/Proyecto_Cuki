extends StaticBody2D

var can_be_used = true

enum MotorState
{
	ON,
	OFF,
	OVERHEATED
}

@export var colorhex:String = ""
@export var motorState = MotorState.OFF

var state:
	set(new_state):
		if can_be_used:
			if state == true:
				$AnimationPlayer.play("On")
			else:
				$AnimationPlayer.play("Off")
			state = new_state

func refreshColorState():
	if motorState == MotorState.OFF:
		$AnimationPlayer.play("Off")
	if motorState == MotorState.ON:
		$AnimationPlayer.play("On")
	if motorState == MotorState.OVERHEATED:
		$AnimationPlayer.play("Overheat")

func setMotorState(newMotorState):
	motorState = newMotorState
	if motorState == MotorState.OFF:
		state = false
	if motorState == MotorState.ON:
		state = true
	if motorState == MotorState.OVERHEATED:
		state = false

func _ready():
	$Color.color = Color(colorhex)
	refreshColorState()

func _on_area_2d_area_entered(area):
	if area.name == "Tar" && motorState != MotorState.OVERHEATED:
		setMotorState(MotorState.ON)
	if area.name == "Flame":
		setMotorState(MotorState.OVERHEATED)
	if area.name == "Ice" && motorState == MotorState.OVERHEATED:
		setMotorState(MotorState.ON)
	refreshColorState()
