class_name TacticsOpponent
extends TacticsParticipant
## Handles opponent AI actions and decision-making
## 
## Dependencies: [TacticsParticipant]
## Used by: [TacticsLevel]


#region: --- Props ---
#endregion


#region: --- Methods ---
## Initiates dependencies & selects a default pawn
func select_first_pawn() -> void:
	curr_pawn = get_children().front()


## Whether every child pawn is configured
func _is_pawn_configured() -> bool:
	for pawn in get_children():
		if not pawn.configure():
			return false
	return true


## Opponent pawn selection
func choose_pawn() -> void:
	arena.reset_all_tile_markers()
	for p in get_children():
		if p.can_act():
			curr_pawn = p 
			stage = 1
			return


## Move towards the nearest enemy
func chase_nearest_enemy() -> void:
	arena.reset_all_tile_markers()
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.stats.jump, get_children())
	arena.mark_reachable_tiles(curr_pawn.get_tile(), curr_pawn.stats.mp)
	
	var to = arena.get_nearest_target_adjacent_tile(curr_pawn, targets.get_children())
	curr_pawn.pathfinding_tilestack = arena.get_pathfinding_tilestack(to)
	tactics_camera.target = to
	stage = 2


## Whether pawn movement is finished
func is_pawn_done_moving() -> void:
	if curr_pawn.pathfinding_tilestack.is_empty():
		stage = 3


## Choose the target pawn to attack
func choose_pawn_to_attack() -> void:
	arena.reset_all_tile_markers()
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.stats.range)
	arena.mark_attackable_tiles(curr_pawn.get_tile(), curr_pawn.stats.range)
	
	attackable_pawn = arena.get_weakest_attackable_pawn(targets.get_children())
	if attackable_pawn:
		attackable_pawn.service.display_pawn_stats(true)
		tactics_camera.target = attackable_pawn
	stage = 4


## Ensures all pawns are configured. Returns true if all pawns are.
func post_configure() -> bool:
	return _is_pawn_configured()
#endregion
