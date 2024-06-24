extends Totem

func _process(delta):
	if activated == true && get_tree().get_nodes_in_group("totem_enemies").size() == 0:
		roundEnding()
		generateEnemies()
	if Cuki != null:
		if Cuki.elemental_state.getState() != 5:
			Cuki.elemental_state.contactWithElement(5)
