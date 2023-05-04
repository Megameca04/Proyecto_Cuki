extends Node

enum ElementalState { None, Water, Venom, Tar, Fire, Ice, ParalIce, Shock }
enum ElementalEvent { Cured, Wet, Poisoned, Dirty, Torched, Freezed, Shocked }
enum ElementalEffect { DoubleDamage, Damage }

var state = ElementalState.None

func _ready():
	pass

func _process(delta):
	pass

func contactWithElement(elementalEvent):
	if (elementalEvent == ElementalEvent.Cured):
		state = ElementalState.None
		return state
	if (elementalEvent == ElementalEvent.Wet):
		if (state == ElementalState.Fire && state == ElementalState.Tar && state == ElementalState.Venom):
			state = ElementalState.None
			return state
		if (state == ElementalState.Shock):
			return effectWithElement(elementalEvent)
		if (state == ElementalState.Ice):
			state == ElementalState.ParalIce
			return state
	if (elementalEvent == ElementalEvent.Poisoned):
		if (state == ElementalState.None):
			state = ElementalState.Venom
			return state
	if (elementalEvent == ElementalEvent.Dirty):
		if (state == ElementalState.None):
			state = ElementalState.Tar
			return state
		if (state == ElementalState.Fire):
			return effectWithElement(elementalEvent)
	if (elementalEvent == ElementalEvent.Torched):
		if (state == ElementalState.None):
			state = ElementalState.Shock
			return state
		if (state == ElementalState.Ice):
			state = ElementalState.None
			return state
		if (state == ElementalState.ParalIce):
			state = ElementalState.None
			return state
	if (elementalEvent == ElementalEvent.Freezed):
		if (state == ElementalState.None):
			state = ElementalState.Ice
			return state
	if (elementalEvent == ElementalEvent.Shocked):
		if (state == ElementalState.None):
			state = ElementalState.Shock
			return state

func effectWithElement(elementalEvent):
	if (elementalEvent == ElementalEvent.Wet && state == ElementalState.Shock):
		return ElementalEffect.Damage
	if (elementalEvent == ElementalEvent.Dirty && state == ElementalState.Fire):
		return ElementalEffect.DoubleDamage
