extends Resource
class_name Soldier

## Represents a single soldier in the player's party.
## Stats are clamped 0-100. Hitting 0 on Health or Hydration triggers a death event.
## Morale affects decision point outcomes (exact formulas TBD).
## Stat structure finalized 2026-09-13: Health (renamed from Stamina, broader
## scope), Hydration (new), Morale. Hunger was removed entirely, not folded
## into anything else.

signal died(cause: String)

@export var soldier_name: String = ""
@export var is_main: bool = false ## True for the one player-controlled soldier.

@export_range(0, 100) var health: float = 100.0
@export_range(0, 100) var hydration: float = 100.0
@export_range(0, 100) var morale: float = 100.0

@export var is_alive: bool = true
@export var death_cause: String = ""

func apply_stat_delta(stat: String, amount: float) -> void:
	if not is_alive:
		return
	match stat:
		"health":
			health = clamp(health + amount, 0.0, 100.0)
		"hydration":
			hydration = clamp(hydration + amount, 0.0, 100.0)
		"morale":
			morale = clamp(morale + amount, 0.0, 100.0)
		_:
			push_warning("Soldier.apply_stat_delta: unknown stat '%s'" % stat)
	_check_for_death()

func _check_for_death() -> void:
	if not is_alive:
		return
	# health checked first — if both hit 0 simultaneously, health's cause wins.
	# TODO: once DecisionEvent can reduce Health for other reasons (Injuries,
	# Sickness, etc.), this cause message will need to become dynamic instead
	# of hardcoded to the Relentless Pace exhaustion case.
	if health <= 0.0:
		_die("Shot/beaten for falling behind")
	elif hydration <= 0.0:
		_die("Dehydration")

func _die(cause: String) -> void:
	is_alive = false
	death_cause = cause
	died.emit(cause)
