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
@onready var _state_time_length : Timer = $StateLenght
@onready var _damage_cycle : Timer  = $DamageCycle

##Funcion que detecta cual debe ser la respuesta según el elemento aplicado.
func contactWithElement(elementalEvent : int):
	
	#Cuando el elemento es Agua 
	if (elementalEvent == 3):
		contactWithWater()
	
	#Cuando el elemento incluye un efecto que dura en el tiempo
	if (elementalEvent == 5 or elementalEvent == 1 or elementalEvent == 4):
		contactWithTemporalState(elementalEvent)
	
	#Cuando el elemento afecta el movimiento de la entidad
	if (elementalEvent == 6 or elementalEvent == 2):
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

##Funcion que detecta cual debe ser la respuesta a ser golpeado con el elemento
##Agua dependiendo del estado actual.
func contactWithWater():
	
	#Si la entidad tiene el efecto de congelamiento y no está ni paralizada ni con alquitran
	if (
			_current_element == Elements.FREEZE and _current_element != Elements.PARALYZED
			and _current_element != Elements.TAR
	):
		_current_element = Elements.ICEBLOCK
		_state_time_length.set_wait_time(state_length)
		_state_time_length.start()
		return
	
	#Si la entidad tiene el efecto de alquitran
	if _current_element == Elements.TAR:
		_current_element = Elements.NONE
		return
	
	#Si la entidad tiene el efecto de Veneno, y no tiene el efecto de Fuego o
	#Fuego intenso
	if (
			_current_element == Elements.POISON or _current_element == Elements.FIRE
			or _current_element == Elements.INTENSEFIRE
		):
		_current_element = Elements.NONE
		return
	
	#Si la entidad no tiene un efecto
	if _current_element == Elements.NONE:
		_current_element = Elements.WET
		_state_time_length.set_wait_time(state_length)
		_state_time_length.start()
	
	#Si la entidad tiene el efecto de Paralizado
	if _current_element == Elements.PARALYZED:
		_current_element = Elements.ELECTROSHOCK
		_damage_cycle.start()
		_state_time_length.set_wait_time(state_length)
		_state_time_length.start()

##Funcion que detecta cual debe ser la respuesta a un elemento si este tiene un
##efecto persistente en un intervalo de tiempo
func contactWithTemporalState(elementalEvent : int):
	
	var current_state_length = state_length
	
	#Si no hay un efecto activo en la entidad
	if _current_element == Elements.NONE:
		
		#Si el elemento recibido es Veneno y la entidad no está mojada
		if (elementalEvent == 5 && _current_element != Elements.WET):
			_current_element = Elements.POISON
		
		#Si el elemento recibido es Fuego 
		if elementalEvent == 1:
			
			#Si el elemento actual es Alquitran
			if _current_element == Elements.TAR:
				_current_element = Elements.INTENSEFIRE
				_state_time_length.set_wait_time(_state_time_length.get_wait_time() - state_length / 2)
			
			else:
				_current_element = Elements.FIRE
				_state_time_length.set_wait_time(state_length)
			
			_state_time_length.start()
			_damage_cycle.start()
			return
		
		#Si el elemento recibido es Congelado
		if elementalEvent == 4:
			_current_element = Elements.FREEZE
		
		_state_time_length.set_wait_time(state_length)
		_state_time_length.start()
	
	#Si el elemento actual es mojado y el efecto recibido es congelado
	if (_current_element == Elements.WET && elementalEvent == 4):
		
		_current_element = Elements.ICEBLOCK
		_state_time_length.set_wait_time(state_length)
		_state_time_length.start()

##Funcion que detecta cual debe ser la respuesta a un elemento si este afecta
##la movilidad de la entidad
func contactWithMovementState(elementalEvent):
	
	#Si no hay un efecto activo en la entidad
	if _current_element == Elements.NONE:
		
		#Si el elemento recibido es Alquitran 
		if (elementalEvent == "Tar"):
			
			#Si el elemento actual es Fuego
			if (_current_element == Elements.FIRE):
				 
				_current_element = Elements.NONE
				_current_element = Elements.INTENSEFIRE
				_state_time_length.set_wait_time(_state_time_length.get_wait_time() - state_length / 2)
				return
				
			else:
				
				_current_element = Elements.TAR
			
		
		#Si el elemento recibido es Paralisis
		if (elementalEvent == "Shock"):
			
			_current_element = Elements.PARALYZED
			
			#Si el elemento actual es Agua
			if (_current_element == Elements.WET):
				
				_current_element = Elements.ELECTROSHOCK
				_damage_cycle.start()
		
		_state_time_length.set_wait_time(state_length)
		_state_time_length.start()

##Funcion que establece el elemento actual a Ningugo
func cureEverything():
	_current_element = Elements.NONE
	_damage_cycle.stop()

##Función que retorna el elemento actual
func getState():
	return _current_element

func _on_elemental_timer_timeout():
	cureEverything()

func _on_elemental_damage_timeout():
	emit_signal("temporal_damage")
	_damage_cycle.start()
