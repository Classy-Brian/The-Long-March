extends Resource
class_name Soldier

## Represents a single soldier in the player's party.
## Stats are clamped 0-100. Hitting 0 on Stamina or Hunger triggers a death event.
## Morale affects decision point outcomes (exact formulas TBD)

signal died(cause: String)

@export var soldier_name: String = ""
@export var is_main: bool = false ## True for the one player-controlled soldier.

@export_range(0, 100) var stamina: float = 100.0
@export_range(0, 100) var hunger: float = 100.0
@export_range(0, 100) var morale: float = 100.0

@export var is_alive: bool = true
@export var death_cause: String = ""

func apply_stat_delta(stat: String, amount: float) -> void:
	if not is_alive: # Dead soldiers don't take further stat changes
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
	# Stamina checked first - if both hit 0 simultaneously, stamin's cause wins
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
