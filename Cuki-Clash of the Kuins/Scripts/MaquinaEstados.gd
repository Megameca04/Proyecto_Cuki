class_name MaquinaEstados extends Node

@onready var nodo_controlado = self.owner

@export var estado_defecto : EstadoBase

var estado_actual : EstadoBase = null

func _ready():
	call_deferred("_iniciar_estado_base")

func _process(delta):
	if estado_actual and estado_actual.has_method("en_process"):
		estado_actual.en_process()

func _physics_process(delta):
	if estado_actual and estado_actual.has_method("en_physics_process"):
		estado_actual.en_physics_process()

func _input(event):
	if estado_actual and estado_actual.has_method("en_input"):
		estado_actual.en_input()

func _unhandled_input(event):
	if estado_actual and estado_actual.has_method("en_unhandled_input"):
		estado_actual.en_unhandled_input()

func _unhandled_key_input(event):
	if estado_actual and estado_actual.has_method("en_unhandled_key_input"):
		estado_actual.en_unhandled_key_input()

func _iniciar_estado_base():
	estado_actual = estado_defecto
	_iniciar_estados()

func _iniciar_estados():
	estado_actual.nodo_controlado = nodo_controlado
	estado_actual.maq_estados = self
	estado_actual.start()

func cambiar_estado(nuevo_estado : String):
	if estado_actual and estado_actual.has_method("finalizar"):
		estado_actual.finalizar()
	
	estado_actual = get_node(nuevo_estado)
	_iniciar_estados()
