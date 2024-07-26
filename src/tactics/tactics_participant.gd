class_name TacticsParticipant
extends Node3D
## Handles participant (i.e. Player & Opponent) actions and decision-making
## 
## Parent of: [TacticsPlayer], [TacticsOpponent]


#region: --- Props ---
var arena: TacticsArena = null
var stage: int = 0 ## Controls the current stage in the pawn round process
var tactics_camera: TacticsCamera = null
var ui_control: TacticsControls = null
var curr_pawn: TacticsPawn = null ## Currently selected pawn
var attackable_pawn: TacticsPawn = null ## Storage for an attackable pawn

var player: TacticsPlayer
var opponent: TacticsOpponent

var targets: Node = null
#endregion


#region: --- Processing ---
func _ready():
	player = $Player
	opponent = $Opponent
#endregion


#region: --- Methods ---
## Main function for the participant's actions. Controls the flow of actions based on the current stage.
func act(delta: float, is_player: bool, parent) -> void:
	if is_player:
		parent.move_camera()
		parent.camera_rotation()
		ui_control.set_actions_menu_visibility(stage in [1, 2, 3, 5, 6], curr_pawn)

		match stage:
			0: parent.select_pawn()
			1: parent.show_available_pawn_actions()
			2: parent.show_available_movements()
			3: parent.select_new_location()
			4: parent.move_pawn()
			5: parent.display_attackable_targets()
			6: parent.select_pawn_to_attack()
			7: attack_pawn(delta, true)
	else:
		targets = get_parent().get_node("Player")
		ui_control.set_actions_menu_visibility(false, null)

		match stage:
			0: parent.choose_pawn()
			1: parent.chase_nearest_enemy()
			2: parent.is_pawn_done_moving()
			3: parent.choose_pawn_to_attack()
			4: attack_pawn(delta, false)


## Initiates dependencies
func configure(my_arena: TacticsArena, my_camera: TacticsCamera, my_control: TacticsControls, is_player: bool, parent: Node3D) -> void:
	tactics_camera = my_camera
	arena = my_arena
	ui_control = my_control
	if is_player:
		parent.init_player()
	else:
		parent.select_first_pawn()


## Whether the opponent can act
func can_act(is_player, parent: Node3D) -> bool:
	for p in parent.get_children():
		if p.can_act():
			return true
	return stage > 0


## Resets all pawns turn
func reset_turn(is_player, parent) -> void:
	for p in parent.get_children():
		p.reset_turn()


## Defines pawn-to-pawn attack operations
func attack_pawn(delta: float, is_player: bool) -> void:
	if not attackable_pawn: 
		curr_pawn.can_attack = false
	else:
		if not curr_pawn.on_attack(attackable_pawn, delta): 
			return

		attackable_pawn.service.display_pawn_stats(false)
		tactics_camera.target = curr_pawn

	attackable_pawn = null

	if not curr_pawn.can_act() or not is_player:
		stage = 0
	elif curr_pawn.can_act() and is_player:
		stage = 1
