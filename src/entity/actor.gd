class_name Actor
extends Entity
## Maps the Actor Model. Edit & merge as needed.
##
## Actor components:
## - 


#region: --- Props ---
static var level: int ## Player Level
static var armor: int ## Replenishable coating of extra health. Armor erodes over damage.
static var ap: int ## Action Points. Usual skill cost: 1-2-3. Finisher: 4. Endgame: 9 AP max.
static var mp: int ## Movement. Average: 3-5 (base). Endgame: 9 max.
static var crit_rate: int ## Critical Rate. Percentile chance to inflict crit dmg. Max: 65%
static var crit_dmg: int ## Extra critical Damage. Base: +50% DMG, Max: +200%.
static var range: int ## How far you can shoot spells & projectiles.
static var def: int ## Defense (damage resist). Max: 15
static var stab: int ## Stability (move resist). 
static var resi: int ## Resilience (AP/MP resist).
#endregion

#region: --- Processing ---
#endregion


#region: --- Methods ---
#endregion
