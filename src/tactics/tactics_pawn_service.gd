extends Node
class_name TacticsPawnService
## Helper & connector methods for the Pawn logic
## 
## Used by: [TacticsArena], [TacticsTile], [TacticsPawn]

#region: --- Props ---
enum PAWN_CLASSES {Knight, Archer, Chemist, Cleric, Skeleton, SkeletonCPT, SkeletonMage}
enum PAWN_STRATEGIES {Tank, Flank, Support}
const KNIGHT_SPRITE = "res://assets/textures/actor/character/chr_pawn_knight.png"
const ARCHER_SPRITE = "res://assets/textures/actor/character/chr_pawn_archer.png"
const CHEMIST_SPRITE = "res://assets/textures/actor/character/chr_pawn_chemist.png"
const CLERIC_SPRITE = "res://assets/textures/actor/character/chr_pawn_mage.png"
const SKELETON_CPT_SPRITE = "res://assets/textures/actor/mob/chr_pawn_skeleton_cpt.png"
const SKELETON_SPRITE = "res://assets/textures/actor/mob/chr_pawn_skeleton.png"
const SKELETON_MAGE_SPRITE = "res://assets/textures/actor/mob/chr_pawn_skeleton_mage.png"
#endregion

#region: --- Methods ---
# ----- mats & sprites -----
static func get_pawn_sprite(pawn_class):
	match pawn_class:
		0: return load(KNIGHT_SPRITE)
		1: return load(ARCHER_SPRITE)
		2: return load(CHEMIST_SPRITE)
		3: return load(CLERIC_SPRITE)
		4: return load(SKELETON_SPRITE)
		5: return load(SKELETON_CPT_SPRITE)
		6: return load(SKELETON_MAGE_SPRITE)

# ----- movement -----
static func get_pawn_move_radius(pawn_class):
	match pawn_class:
		0: return 3
		1: return 5
		2: return 4
		3: return 4
		4: return 5
		5: return 3
		6: return 4

static func vector_remove_y(vector):
	return vector * Vector3(1,0,1)

static func vector_distance_without_y(b, a):
	return vector_remove_y(b).distance_to(vector_remove_y(a))

# REMAP TO PAWN STATS CLASS
static func get_pawn_jump_height(pawn_class):
	match pawn_class:
		0: return 0.5
		1: return 3
		2: return 1
		3: return 1
		4: return 3
		5: return 0.5
		6: return 1

static func get_pawn_attack_radius(pawn_class):
	match pawn_class:
		0: return 1
		1: return 6
		2: return 3
		3: return 3
		4: return 6
		5: return 1
		6: return 3

static func get_pawn_attack_power(pawn_class):
	match pawn_class:
		0: return 20
		1: return 10
		2: return 12
		3: return 12
		4: return 10
		5: return 20
		6: return 12

static func get_pawn_health(pawn_class):
	match pawn_class:
		0: return 50
		1: return 35
		2: return 30
		3: return 25
		4: return 35
		5: return 50
		6: return 30
#endregion
