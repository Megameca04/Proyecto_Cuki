##Componente que maneja el cambio entre estados de las entidades que pueden ser
##afectados por estos
class_name ElementalState extends Node

##Señal que se debe conectar con funciones que generen daño a la entidad
##conectada.
signal temporal_damage

##Lista de elementos disponibles
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

##Variable que determina la duración de un elemento.
@export var state_length : int = 5

##Efecto elemental que tiene la entidad en el momento.
var _current_element : int = Elements.NONE

#Referencia a los nodos que miden duración del efecto y la repetición de daño
@onready var _StateTimeLength : Timer = $StateLenght
@onready var _DamageCycle : Timer  = $DamageCycle

##Funcion que detecta cual debe ser la respuesta según el elemento aplicado.
func contactWithElement(elementalEvent):
	
	#Cuando el elemento es Agua 
	if (elementalEvent == "Water"):
		contactWithWater()
	
	#Cuando el elemento incluye un efecto que dura en el tiempo
	if (elementalEvent == "Poison" or elementalEvent == "Flame" or elementalEvent == "Freeze"):
		contactWithTemporalState(elementalEvent)
	
	#Cuando el elemento afecta el movimiento de la entidad
	if (elementalEvent == "Tar" or elementalEvent == "Shock"):
		contactWithMovementState(elementalEvent)

##Funcion que detecta cual debe ser la respuesta según un conjunto de elementos
##aplicado.
func contactWithElementGroup(elementalGroup):
	
	#Iteración por cada elemento de la lista
	for i in range(0, elementalGroup.size()):
		
		#Cuando el elemento es Agua 
		if (elementalGroup[i] == "Water"):
			contactWithWater()
		
		#Cuando el elemento incluye un efecto que dura en el tiempo
		if (elementalGroup[i] == "Poison" or elementalGroup[i] == "Flame" or elementalGroup[i] == "Freeze"):
			contactWithTemporalState(elementalGroup[i])
		
		#Cuando el elemento afecta el movimiento de la entidad
		if (elementalGroup[i] == "Tar" or elementalGroup[i] == "Shock"):
			contactWithMovementState(elementalGroup[i])


func contactWithWater():
	
	if (_current_element == Elements.FREEZE and _current_element != Elements.PARALYZED and _current_element != Elements.TAR):
		_current_element = Elements.ICEBLOCK
		_StateTimeLength.set_wait_time(state_length)
		_StateTimeLength.start()
		return
	
	if (_current_element == Elements.TAR):
		_current_element = Elements.NONE
		return
	
	if (_current_element == Elements.POISON or _current_element == Elements.FIRE or _current_element == Elements.INTENSEFIRE):
		_current_element = Elements.NONE
		return
		
	if (_current_element == Elements.NONE):
		_current_element = Elements.WET
		_StateTimeLength.set_wait_time(state_length)
		_StateTimeLength.start()
	
	if (_current_element == Elements.PARALYZED):
		_current_element = Elements.ELECTROSHOCK
		_DamageCycle.start()
		_StateTimeLength.set_wait_time(state_length)
		_StateTimeLength.start()

func contactWithTemporalState(elementalEvent : String):
	
	var current_state_length = state_length
	
	if _current_element == Elements.NONE:
		
		if (elementalEvent == "Poison" && _current_element != Elements.WET):
			_current_element = Elements.POISON
		
		if (elementalEvent == "Flame"):
			
			if (_current_element == Elements.TAR):
				_current_element = Elements.INTENSEFIRE
				_StateTimeLength.set_wait_time(_StateTimeLength.get_wait_time() - state_length / 2)
			
			else:
				_current_element = Elements.FIRE
				_StateTimeLength.set_wait_time(state_length)
				_StateTimeLength.start()
				
			
			_DamageCycle.start()
			return
		
		if (elementalEvent == "Freeze"):
			_current_element = Elements.FREEZE
		
		_StateTimeLength.set_wait_time(state_length)
		_StateTimeLength.start()
	
	if (_current_element == Elements.WET && elementalEvent == "Freeze"):
		
		_current_element = Elements.ICEBLOCK
		_StateTimeLength.set_wait_time(state_length)
		_StateTimeLength.start()

func contactWithMovementState(elementalEvent):
	
	if (_current_element == Elements.NONE):
		
		if (elementalEvent == "Tar"):
			
			if (_current_element == Elements.FIRE):
				 
				_current_element = Elements.NONE
				_current_element = Elements.INTENSEFIRE
				_StateTimeLength.set_wait_time(_StateTimeLength.get_wait_time() - state_length / 2)
				return
				
			else:
				
				_current_element = Elements.TAR
			
		
		if (elementalEvent == "Shock"):
			
			_current_element = Elements.PARALYZED
			
			if (_current_element == Elements.WET):
				
				_current_element = Elements.ELECTROSHOCK
				_DamageCycle.start()
			
		
		_StateTimeLength.set_wait_time(state_length)
		_StateTimeLength.start()

func cureEverything():
	_current_element = Elements.NONE

func getState():
	return _current_element

func _on_elemental_timer_timeout():
	cureEverything()

func _on_elemental_damage_timeout():
	emit_signal("temporal_damage")
	_DamageCycle.start()
