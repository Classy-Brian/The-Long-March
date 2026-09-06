extends Resource
class_name Soldier

## Represents a single soldier in the player's party.
## Stats are clamped 0-100. Hitting 0 on Stamina or Hunger triggers a death event.
## Morale affects escape odds and event outcomes (exact formulas TBD -
## see Knowledge/game-design-one-pager.md).

signal died(cause: String)

@export var soldier_name: String = ""
@export var is_main: bool = false ## True for the one player-controlled soldier.

@export_range(0, 100) var stamina: float = 100.0
@export_range(0, 100) var hunger: float = 100.0
@export_range(0, 100) var morale: float = 100.0

@export var is_alive: bool = true
@export var death_cause: String = ""

func apply_stat_delta(stat: String, amount: float) -> void:
	if not is_alive:
		return
	match stat:
		"stamina":
			stamina = clamp(stamina + amount, 0.0, 100.0)
		"hunger":
			hunger = clamp(hunger + amount, 0.0, 100.0)
		"morale":
			morale = clamp(morale + amount, 0.0, 100.0)
		_:
			push_warning("Soldier.apply_stat_delta: unknown stat '%s'" % stat)
	_check_for_death()

func _check_for_death() -> void:
	if not is_alive:
		return
	if stamina <= 0.0:
		_die("Shot/beaten for falling behind")
	elif hunger <= 0.0:
		_die("Starvation")

func _die(cause: String) -> void:
	is_alive = false
	death_cause = cause
	died.emit(cause)
