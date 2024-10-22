class_name MaquinaEstados extends Node

@onready var nodo_c = self.owner

@export var estado_defecto : EstadoBase

var estado_actual : EstadoBase = null

func _ready():
	call_deferred("_iniciar_estado_base")

func _process(delta):
	if estado_actual and estado_actual.has_method("en_process"):
		estado_actual.en_process(delta)

func _physics_process(delta):
	if estado_actual and estado_actual.has_method("en_physics_process"):
		estado_actual.en_physics_process(delta)

func _input(event):
	if estado_actual and estado_actual.has_method("en_input"):
		estado_actual.en_input(event)

func _unhandled_input(event):
	if estado_actual and estado_actual.has_method("en_unhandled_input"):
		estado_actual.en_unhandled_input(event)

func _unhandled_key_input(event):
	if estado_actual and estado_actual.has_method("en_unhandled_key_input"):
		estado_actual.en_unhandled_key_input(event)

func _iniciar_estado_base():
	estado_actual = estado_defecto
	_iniciar_estados()

func _iniciar_estados():
	estado_actual.nodo_c = self.nodo_c
	estado_actual.maq_estados = self
	if estado_actual.has_method("iniciar"):
		estado_actual.iniciar()

func cambiar_estado(nuevo_estado : String):
	if estado_actual and estado_actual.has_method("detener"):
		estado_actual.detener()
	
	estado_actual = get_node(nuevo_estado)
	_iniciar_estados()
