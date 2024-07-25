class_name Stats
extends Node
## 


signal health_changed(new)
signal health_depleted()

var modifiers = {}

var profession: String
var level: int = 1
# Base Stats
var ap: int
var mp: int ## The radius the pawn can move
var jump: int
var max_health: int
var curr_health: int
var armor: int
var sprite: String
# Offensive
var attack_power: int
var crit_rate: int ## Critical Rate. Percentile chance to inflict crit dmg. Max: 65%
var crit_dmg: int ## Extra critical Damage. Base: +30% DMG, Max: +100%.
var range: int
# Defensive
var def: int ## Defense (chance to resist damage). Max: 65%
var stab: int ## Stability (move resist). 
var resi: int ## Resilience (AP/MP resist).


func init(stats: StatsResource) -> void:
	profession = stats.profession
	level = stats.level
	ap = stats.ap
	mp = stats.mp
	set_jump()
	max_health = stats.max_health
	curr_health = max_health
	armor = stats.armor
	sprite = stats.sprite
	attack_power = stats.attack_power
	crit_rate = stats.crit_rate
	crit_dmg = stats.crit_dmg
	range = stats.range
	def = stats.def
	stab = stats.stab
	resi = stats.resi


func take_damage() -> void:
	pass
func heal() -> void:
	pass

# Getters & Setters
func set_jump() -> void:
	jump = floor(mp / 2)
## Provided a health operation as a parameter (e.g. "-2", "1"), adds the value to current health
func update_curr_health(new: int) -> void:
	curr_health = clamp(curr_health + new, 0, max_health)
