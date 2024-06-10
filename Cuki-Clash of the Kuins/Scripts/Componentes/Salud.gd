##Componente que mantiene el registro de la salud de cualquier entidad que lo tenga.
class_name Salud extends Node

##Se emite cuando la cantidad maxima de salud es cambiada, [code]new_max[/code] indica el nuevo
##valor de la vida maxima.
signal max_changed(new_max)

##Se emite cuando cambia el valor de salud actual, [code]new_amount[/code] especifica el nuevo valor
##de la vida.
signal changed(new_amount)

signal depleted() ##Se emite cuando la salud llega a 0.

##Valor que contiene la cantidad maxima de vida de la entidad.
@export var max_amount: int:
	
	get: #Regresa la cantidad maxima sin ninguna alteración.
		return(max_amount)
	
	#Se asegura que la nueva salud maxima no sea menor a 1, iguala la salud maxima actual
	#a la nueva salud maxima y emite la señal `max_changed`.
	set(value):
		max_amount = value 
		max_amount = max(1, value)
		emit_signal("max_changed", max_amount)

##Valor que contiene la cantidad actual de vida de la entidad.
@onready var current: int:
	
	#Regresa la cantidad maxima sin ninguna alteración.
	get:
		return(current)
	
	#Establece la salud actual al valor del parametro ingresado, se asegura que la salud actual esté
	#entre 0 y la salud maxima y emite la señal `vida_cambiada`.
	set(value):
		current = value
		current= clamp(current, 0, max_amount)
		emit_signal("changed", current)
		
		if current == 0:
			emit_signal("depleted")

#Establece la salud actual al valor de la cantidad del nodo, y la inicializa.
func _ready():
	current = max_amount
	initialize()

#inicia el nodo, emitiendo las señales `max_cambiado` y `vida_cambiada`.
func initialize():
	emit_signal("max_changed", max_amount) 
	emit_signal("changed", current)

