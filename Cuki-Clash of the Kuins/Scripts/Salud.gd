extends Node

signal max_changed(new_max) #se emite cuando hay cambio en la salud maxima
signal changed(new_amount) #se emite cuando cambia la salud actual
signal depleted() #se emite cuando la salud llega a 0

@export var max_amount: int:
	get:
		return(max_amount)
	set(value):
		max_amount = value #la salud maxima será igual al parametro ingresado
		max_amount = max(1, value) #se asegura que la nueva salud no sea menor a 1
		emit_signal("max_changed", max_amount) # emite la señal max_changed()

@onready var current: int:
	get:
		return(current)
	set(value):
		current = value 	 #la salud actual pasa a ser el parametro ingresado
		current= clamp(current, 0, max_amount) #se asegura que la salud actual esté entre 0 y la salud maxima
		emit_signal("changed", current) #emite la señal changed()
		if current == 0: #si la salud llega a 0
			emit_signal("depleted") #emite la señal depleted()

func _ready(): #cuando el nodo inicia su ejecución
	current = max_amount
	initialize()

func initialize(): #inicia el nodo, principalmente se conecta con la barra de salud
	emit_signal("max_changed", max_amount) # emite la señal max_changed()
	emit_signal("changed", current) #emite la señal changed()	

