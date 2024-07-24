class_name StatsResource
extends Resource
## The attributes of a game actor.


@export var profession: String = ""
#enum PROFESSIONS {
		#Knight, 
		#Archer, 
		#Chemist, 
		#Cleric,
		#Skeleton, 
		#SkeletonCPT, 
		#SkeletonMage,
	#}

@export var level: int = 1
@export_group("Base Stats")
@export var ap: int = 3 ## Action Points. Usual skill cost: 1-2-3. Finisher: 4. Endgame: 9 AP max.
@export var mp: int = 3 ## Movement. Average: 3-5 (base). Endgame: 9 max.
@export var max_health: int = 5
@export var armor: int = 0 ## Replenishable coating of extra health. Armor erodes over damage.
@export_file("*.png") var sprite: String = "res://assets/textures/actor/" ## Path to the Sprite.
@export_subgroup("Offensive")
@export var range: int = 1 ## How far you can project your basic attack.
@export var attack_power: int = 1 ## How far you can project your basic attack.
@export var crit_rate: int = 5 ## Critical Rate. Percentile chance to inflict crit dmg. Max: 65%
@export var crit_dmg: int = 30 ## Extra critical Damage. Base: +30% DMG, Max: +100%.
@export_subgroup("Defensive")
@export var def: int = 0 ## Defense (damage resist). Max: 15
@export var stab: int = 0 ## Stability (move resist). 
@export var resi: int = 0 ## Resilience (AP/MP resist).
