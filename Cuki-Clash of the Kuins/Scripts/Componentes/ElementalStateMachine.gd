class_name ElementalState extends Node

signal temporal_damage

enum Elements {
	NONE,			#0
	FIRE,			#1
	PARALYZED,		#2
	WET,			#3
	FREEZE, 		#4
	POISON, 		#5
	TAR,			#6
	INTENSEFIRE,	#7
	ELECTROSHOCK,	#8
	ICEBLOCK 		#9
}

@export var state_length : int = 5

var _current_element = Elements.NONE

@onready var StateTimeLength = $StateLenght
@onready var DamageCycle = $DamageCycle

func contactWithElement(elementalEvent):
	
	if (elementalEvent == "Water"):
		contactWithWater()
	
	if (elementalEvent == "Poison" or elementalEvent == "Flame" or elementalEvent == "Freeze"):
		contactWithTemporalState(elementalEvent)
	
	if (elementalEvent == "Tar" or elementalEvent == "Shock"):
		contactWithMovementState(elementalEvent)

func contactWithElementGroup(elementalGroup):
	
	for i in range(0, elementalGroup.size()):
		
		if (elementalGroup[i] == "Water"):
			contactWithWater()
		
		if (elementalGroup[i] == "Poison" or elementalGroup[i] == "Flame" or elementalGroup[i] == "Freeze"):
			contactWithTemporalState(elementalGroup[i])
		
		if (elementalGroup[i] == "Tar" or elementalGroup[i] == "Shock"):
			contactWithMovementState(elementalGroup[i])

func contactWithWater():
	
	if (_current_element == Elements.FREEZE and _current_element != Elements.PARALYZED and _current_element != Elements.TAR):
		_current_element = Elements.ICEBLOCK
		StateTimeLength.set_wait_time(state_length)
		StateTimeLength.start()
		return
	
	if (_current_element == Elements.TAR):
		_current_element = Elements.NONE
		return
	
	if (_current_element == Elements.POISON or _current_element == Elements.FIRE or _current_element == Elements.INTENSEFIRE):
		_current_element = Elements.NONE
		return
		
	if (_current_element == Elements.NONE):
		_current_element = Elements.WET
		StateTimeLength.set_wait_time(state_length)
		StateTimeLength.start()
	
	if (_current_element == Elements.PARALYZED):
		_current_element = Elements.ELECTROSHOCK
		DamageCycle.start()
		StateTimeLength.set_wait_time(state_length)
		StateTimeLength.start()

func contactWithTemporalState(elementalEvent : String):
	
	var current_state_length = state_length
	
	if _current_element == Elements.NONE:
		
		if (elementalEvent == "Poison" && _current_element != Elements.WET):
			_current_element = Elements.POISON
		
		if (elementalEvent == "Flame"):
			
			if (_current_element == Elements.TAR):
				_current_element = Elements.INTENSEFIRE
				StateTimeLength.set_wait_time(StateTimeLength.get_wait_time() - state_length / 2)
			
			else:
				_current_element = Elements.FIRE
				StateTimeLength.set_wait_time(state_length)
				StateTimeLength.start()
				
			
			DamageCycle.start()
			return
		
		if (elementalEvent == "Freeze"):
			_current_element = Elements.FREEZE
		
		StateTimeLength.set_wait_time(state_length)
		StateTimeLength.start()
	
	if (_current_element == Elements.WET && elementalEvent == "Freeze"):
		
		_current_element = Elements.ICEBLOCK
		StateTimeLength.set_wait_time(state_length)
		StateTimeLength.start()

func contactWithMovementState(elementalEvent):
	
	if (_current_element == Elements.NONE):
		
		if (elementalEvent == "Tar"):
			
			if (_current_element == Elements.FIRE):
				 
				_current_element = Elements.NONE
				_current_element = Elements.INTENSEFIRE
				StateTimeLength.set_wait_time(StateTimeLength.get_wait_time() - state_length / 2)
				return
				
			else:
				
				_current_element = Elements.TAR
			
		
		if (elementalEvent == "Shock"):
			
			_current_element = Elements.PARALYZED
			
			if (_current_element == Elements.WET):
				
				_current_element = Elements.ELECTROSHOCK
				DamageCycle.start()
			
		
		StateTimeLength.set_wait_time(state_length)
		StateTimeLength.start()

func cureEverything():
	_current_element = Elements.NONE

func getState():
	return _current_element

func _on_elemental_timer_timeout():
	cureEverything()

func _on_elemental_damage_timeout():
	emit_signal("temporal_damage")
	DamageCycle.start()
