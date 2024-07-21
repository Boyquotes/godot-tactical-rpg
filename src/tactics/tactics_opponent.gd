class_name TacticsOpponent
extends Node3D
## Handles __________
##
## Used by: [TacticsLevel]

#region: --- Props ---
var stage = 0
var curr_pawn
var attackable_pawn

var tactics_camera = null
var arena = null
var targets = null

var ui_control: TacticsControls = null
#endregion

#region: --- Methods ---
## Main function for the opponent's actions. Controls the flow of actions for the opponent based on the current stage.
func act(delta) -> void:
	targets = get_parent().get_node("Player")
	ui_control.set_actions_menu_visibility(false, null)
	match stage:
		0: _choose_pawn()
		1: _chase_nearest_enemy()
		2: _is_pawn_done_moving()
		3: _choose_pawn_to_attack()
		4: _attack_pawn(delta)


## Initiates dependencies & selects a default pawn
func configure(my_arena: TacticsArena, 
		my_camera: TacticsCamera, my_ui_control: TacticsControls) -> void:
	tactics_camera = my_camera
	arena = my_arena
	ui_control = my_ui_control
	curr_pawn = get_children().front()


## Whether the opponent can act
func can_act() -> bool:
	for p in get_children():
		if p.can_act(): return true
	return stage > 0


## Resets all pawns turn
func reset_turn() -> void: 
	for p in get_children(): 
		p.reset_turn()


## Whether every child pawn is configured
func _is_pawn_configured() -> bool:
	for pawn in get_children():
		if !pawn.configure():
			return false
	return true


## Opponent pawn selection
func _choose_pawn() -> void:
	arena.reset_all_tile_markers()
	for p in get_children():
		if p.can_act(): curr_pawn = p 
	stage = 1


## Move towards the nearest enemy
func _chase_nearest_enemy() -> void:
	arena.reset_all_tile_markers()
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.jump_height, get_children())
	arena.mark_reachable_tiles(curr_pawn.get_tile(), curr_pawn.move_radius)
	var to = arena.get_nearest_target_adjacent_tile(curr_pawn, targets.get_children())
	curr_pawn.pathfinding_tilestack = arena.get_pathfinding_tilestack(to)
	tactics_camera.target = to
	stage = 2


## Whether pawn movement is finished
func _is_pawn_done_moving() -> void:
	if curr_pawn.pathfinding_tilestack.is_empty(): 
		stage = 3


## Whether pawn movement is finished
func _choose_pawn_to_attack() -> void:
	arena.reset_all_tile_markers()
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.attack_radius)
	arena.mark_attackable_tiles(curr_pawn.get_tile(), curr_pawn.attack_radius)
	attackable_pawn = arena.get_weakest_attackable_pawn(targets.get_children())
	if attackable_pawn: 
		attackable_pawn.display_pawn_stats(true)
		tactics_camera.target = attackable_pawn
	stage = 4 


## Executes the attack on the target pawn. Handles  attack-adjacent logic and resets the stage after the attack is completed.
func _attack_pawn(delta) -> void:
	if !attackable_pawn: 
		curr_pawn.can_attack = false
	else:
		if !curr_pawn.do_attack(attackable_pawn, delta): return
		attackable_pawn.display_pawn_stats(false)
		tactics_camera.target = curr_pawn
	attackable_pawn = null
	stage = 0


## Ensures all pawns are configured. Returns true if all pawns are.
func post_configure() -> bool:
	return _is_pawn_configured()
#endregion
