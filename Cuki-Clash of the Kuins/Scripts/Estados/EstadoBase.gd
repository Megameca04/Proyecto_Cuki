class_name EstadoBase extends Node

@onready var nodo_c : Node = self.owner

var maq_estados : MaquinaEstados

#region metodos comunes
func iniciar():
	pass

func detener():
	pass
#endregion


func en_process(delta : float) -> void:
	pass

func en_physics_process(delta : float) -> void:
	pass

func en_input(event : InputEvent) -> void:
	pass

func en_unhandled_input(event : InputEvent) -> void:
	pass

func en_unhandled_key_input(event : InputEvent):
	pass
