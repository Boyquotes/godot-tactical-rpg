class_name Stats
extends Node
## Placeholder script that essentially replicates the Pawn Expertise Model into its own self-contained Stats class. 
## 
## This class can be made into a Resource Save utility for instantiated characters, for instance. Alternatively, it could pull the appropriate data from a character save and write back to it as needed.

## Dictionary to store modifiers
var modifiers: Dictionary = {}
## Override name for the character
var override_name: String
## Expertise of the character
var expertise: String
## Current level of the character
var level: int = 1

#region Base Stats
## Action Points
var ap: int
## Movement Points (The radius the pawn can move)
var mp: int
## Jump height
var jump: int
## Maximum health
var max_health: int
## Current health
var curr_health: int
## Armor value
var armor: int
## Sprite path
var sprite: String
#endregion

#region Offensive Stats
## Attack power
var attack_power: int
## Critical Rate. Percentile chance to inflict crit dmg. Max: 65%
var crit_rate: int
## Extra critical Damage. Base: +30% DMG, Max: +100%.
var crit_dmg: int
## Attack range
var attack_range: int
#endregion

#region Defensive Stats
## Defense (chance to resist damage). Max: 65%
var def: int
## Stability (move resist)
var stab: int
## Resilience (AP/MP resist)
var resi: int
#endregion

## Initialize stats from a StatsResource
func init(stats: StatsResource) -> void:
	override_name = stats.override_name
	expertise = stats.expertise
	level = stats.level
	ap = stats.ap
	mp = stats.mp
	stats.set_jump()
	max_health = stats.max_health
	curr_health = max_health
	armor = stats.armor
	sprite = stats.sprite
	attack_power = stats.attack_power
	crit_rate = stats.crit_rate
	crit_dmg = stats.crit_dmg
	attack_range = stats.attack_range
	def = stats.def
	stab = stats.stab
	resi = stats.resi

## Provided a health operation as a parameter (e.g. "-2", "1"), adds the value to current health. As a consequence, this function serves for both damage and healing.
func apply_to_curr_health(new: int) -> void:
	print("Target initial health: ", curr_health, " - Applying damage: ", new)
	curr_health = clamp(curr_health + new, 0, max_health) # Apply health change and clamp to valid range
	print("Target final health: ", curr_health)
