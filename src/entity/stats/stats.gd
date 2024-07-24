class_name Stats
extends Node
## 


signal health_changed(new)
signal health_depleted()

var modifiers = {}

var level: int = 1
# Base Stats
var ap: int: get = get_ap, set = set_ap
var mp: int: get = get_mp, set = set_mp
var max_health: int: get = get_max_health, set = set_max_health
var curr_health: int
var armor: int: get = get_armor, set = set_armor
var sprite: String
# Offensive
var attack_power: int
var crit_rate: int ## Critical Rate. Percentile chance to inflict crit dmg. Max: 65%
var crit_dmg: int ## Extra critical Damage. Base: +30% DMG, Max: +100%.
var range: int ## How far you can project your basic attack.
# Defensive
var def: int ## Defense (chance to resist damage). Max: 65%
var stab: int ## Stability (move resist). 
var resi: int ## Resilience (AP/MP resist).


func init(stats: StatsResource) -> void:
	level = stats.level
	ap = stats.ap
	mp = stats.mp
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
func get_ap() -> int:
	return ap
func set_ap(new) -> void:
	ap = new
func get_mp() -> int:
	return mp
func set_mp(new) -> void:
	mp = new
func get_max_health() -> int:
	return max_health 
func set_max_health(new) -> void:
	max_health = new
func get_armor() -> int:
	return armor 
func set_armor(new) -> void:
	armor = new
