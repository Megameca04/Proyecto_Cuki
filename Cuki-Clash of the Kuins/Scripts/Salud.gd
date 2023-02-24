extends Node

signal max_changed(new_max) #se emite cuando hay cambio en la salud maxima
signal changed(new_amount) #se emite cuando cambia la salud actual
signal depleted() #se emite cuando la salud llega a 0

export (int) var max_amount = 20 setget set_max #almacena la salud maxima del nodo
onready var current = max_amount setget set_current #almacena la salud actual del nodo

func _ready(): #cuando el nodo inicia su ejecución
	initialize()

func set_max(new_max): #establece la nueva maxima salud del nodo, función setter de la variable max_amount
	max_amount = new_max #la salud maxima será igual al parametro ingresado
	max_amount = max(1, new_max) #se asegura que la nueva salud no sea menor a 1
	emit_signal("max_changed", max_amount) # emite la señal max_changed()

func set_current(new_value): #establece la nueva salud del nodo, función setter de la variable current
	current = new_value 	 #la salud actual pasa a ser el parametro ingresado
	
	current= clamp(current, 0, max_amount) #se asegura que la salud actual esté entre 0 y la salud maxima
	emit_signal("changed", current) #emite la señal changed()
	
	if current == 0: #si la salud llega a 0
		emit_signal("depleted") #emite la señal depleted()
		get_parent().queue_free() #elimina el nodo padre (sujeto a cambio)

func initialize(): #inicia el nodo, principalmente se conecta con la barra de salud
	emit_signal("max_changed", max_amount) # emite la señal max_changed()
	emit_signal("changed", current) #emite la señal changed()
