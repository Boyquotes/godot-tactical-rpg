class_name TacticsPawnCombatService
extends RefCounted
## Service class for managing combat actions of pawns in the tactics game


## Executes an attack from one pawn to another
##
## @param pawn: The attacking TacticsPawn
## @param target_pawn: The TacticsPawn being attacked
## @param delta: Time elapsed since the last frame
## @return: Whether the attack was completed
func attack_pawn(delta: float, is_player: bool) -> void:
	# Handle case when no attackable pawn is available
	if not res.attackable_pawn:
		res.curr_pawn.res.can_attack = false
	else:
		# Attempt to attack the target pawn
		if not res.curr_pawn.attack_target_pawn(res.attackable_pawn, delta):
			return
		# Hide actions menu and focus camera on attacking pawn
		controls.set_actions_menu_visibility(false, res.attackable_pawn)
		camera.target = res.curr_pawn
	
	# Reset attackable pawn
	res.attackable_pawn = null
	# Reset opponent stats display
	if res.display_opponent_stats:
		res.display_opponent_stats = false
	
	# Determine next stage based on current pawn's ability to act and whether it's a player pawn
	if not res.curr_pawn.can_act() or not is_player:
		res.stage = res.STAGE_SELECT_PAWN
	elif res.curr_pawn.can_act() and is_player:
		res.stage = res.STAGE_SHOW_ACTIONS
