class_name TacticsLevel
extends Node3D
## Tactics system initialization & stage management.
##
## This is the system's top-level script.[br][br]
## Dependencies: [TacticsArena], [TacticsCamera], [TacticsControls], [TacticsOpponent], [TacticsPlayer]


#region: --- Props ---
var player: TacticsPlayer = null
var opponent: TacticsOpponent
var arena: TacticsArena
var camera: TacticsCamera
var ui_control: TacticsControls
var stage: int = 0
#endregion


#region: --- Processing ---
func _ready() -> void:
	player = $Player
	opponent = $Opponent
	arena = $Arena
	camera = $TacticsCamera
	ui_control = $TacticsControls
	
	arena.configure_tiles()
	player.configure(arena, camera, ui_control)
	opponent.configure(arena, camera, ui_control)


func _physics_process(delta) -> void:
	match stage:
		0: _init_turn()
		1: _handle_turn(delta)
#endregion


#region: --- Methods ---
## Checks requirements to begin the first turn.[br]Used by [TacticsPlayer], [TacticsOpponent]
func _init_turn() -> void:
	if player.post_configure() and opponent.post_configure():
		stage = 1


## Turn state management.[br]Used by [TacticsPlayer], [TacticsOpponent]
func _handle_turn(delta) -> void:
	if player.can_act(): 
		player.act(delta)
	elif opponent.can_act(): 
		opponent.act(delta)
	else:
		player.reset()
		opponent.reset()
#endregion
