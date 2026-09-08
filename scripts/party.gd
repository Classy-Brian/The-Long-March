extends Node

## Party manager - registered as an autoload singleton named "Party"
## (see [autoload] in project.godot). Holds the 3 soldiers: one main
## player-controlled soldier plus two background/support soldiers whose
## stats are still tracked. Exact background-soldier mechanics are TBD

signal soldier_died(soldier: Soldier)
signal party_wiped

var soldiers: Array[Soldier] = []

func _ready() -> void:
	_init_default_party()

func _init_default_party() -> void:
	soldiers.clear()
	soldiers.append(_make_soldier("Main Soldier", true))
	soldiers.append(_make_soldier("Soldier B", false))
	soldiers.append(_make_soldier("Soldier C", false))

func _make_soldier(soldier_name: String, is_main: bool) -> Soldier:
	var s := Soldier.new()
	s.soldier_name = soldier_name
	s.is_main = is_main
	
	# Lamda captures 's' so _on_soldier_died knows which soldier died
	# The signal itself only passes 'cause'
	s.died.connect(func(cause: String): _on_soldier_died(s, cause))
	
	return s

func get_main_soldier() -> Soldier:
	for s in soldiers:
		if s.is_main:
			return s
	return null

func living_soldiers() -> Array[Soldier]:
	return soldiers.filter(func(s): return s.is_alive)

func apply_stat_delta_to_all(stat: String, amount: float) -> void:
	for s in soldiers:
		s.apply_stat_delta(stat, amount)

func _on_soldier_died(s: Soldier, cause: String) -> void:
	soldier_died.emit(s)
	if living_soldiers().is_empty():
		party_wiped.emit()
