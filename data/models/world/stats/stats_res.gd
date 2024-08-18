class_name StatsResource
extends Resource
## The attributes of a game actor.

#region Properties
## Override name for the actor
@export var override_name: String = ""
## Expertise of the actor
@export var expertise: String = ""

@export_category("Init")
## Strategy type of the actor
@export_enum("Tank", "Flank", "Physical", "Distance", "Support") var strategy: int
## Current level of the actor
@export var level: int = 1
## Path to the actor's sprite
@export_file("*.png") var sprite: String = "res://assets/textures/actor/"

#region Base Stats
@export_category("Base")
## Action Points. Usual skill cost: 1-2-3. Finisher: 4. Endgame: 9 AP max.
@export var ap: int = 3
## Movement. Average: 3-5 (base). Endgame: 9 max.
@export var mp: int = 3
## Jump height, calculated as half of mp
@export var jump: float = mp / 2.0
## Maximum health of the actor
@export var max_health: int = 5
## Replenishable coating of extra health. Armor erodes over damage.
@export var armor: int = 0
#endregion

#region Offensive Stats
@export_category("Offensive")
## How far you can project your basic attack.
@export var attack_range: int = 1
## Attack power of the actor
@export var attack_power: int = 1
## Critical Rate. Percentile chance to inflict crit dmg. Max: 65%
@export var crit_rate: int = 5
## Extra critical Damage. Base: +30% DMG, Max: +100%.
@export var crit_dmg: int = 30
#endregion

#region Defensive Stats
@export_category("Defensive")
## Defense (damage resist). Max: 15
@export var def: int = 0
## Stability (move resist).
@export var stab: int = 0
## Resilience (AP/MP resist).
@export var resi: int = 0
#endregion


#region Methods
## Calculates and sets the jump height based on mp
func set_jump() -> void:
	jump = floor(mp / 2.0)
#endregion
