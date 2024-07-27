class_name TacticsPlayer
extends TacticsParticipant
## Handles player actions recognition & consequences controller
##
## Dependencies: [TacticsArena], [TacticsCamera], [TacticsControls], [TacticsParticipant]
## Used by: [TacticsLevel]


#region: --- Props ---
var is_joystick = false ## Is the input method a controller?
#endregion


#region: --- Processing ---
func _process(_delta: float) -> void:
	Input.set_mouse_mode(is_joystick)


func _input(event: InputEvent) -> void:
	is_joystick = event is InputEventJoypadButton or event is InputEventJoypadMotion
	ui_control.is_joystick = is_joystick
#endregion


#region: --- Methods ---
# --- camera --- #
## Calls the [TacticsCamera] move_camera() method
func move_camera() -> void:
	var h = -Input.get_action_strength("camera_left") + Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward") - Input.get_action_strength("camera_backwards")
	tactics_camera.move_camera(h, v, is_joystick)


## Calls the [TacticsCamera] rotation & free look features
func camera_rotation() -> void:
	if Input.is_action_just_pressed("camera_rotate_left"): 
		tactics_camera.y_rot -= 90
	elif Input.is_action_just_pressed("camera_rotate_right"): 
		tactics_camera.y_rot += 90
	elif Input.is_action_just_pressed("camera_free_look"): 
		tactics_camera.in_free_look = true


## Selects hovered pawn as curr_pawn
func select_pawn() -> void:
	arena.reset_all_tile_markers()
	if curr_pawn: 
		curr_pawn.service.display_pawn_stats(false)
	curr_pawn = _select_hovered_pawn()
	if not curr_pawn: 
		return

	curr_pawn.service.display_pawn_stats(true)
	if Input.is_action_just_pressed("ui_accept") and curr_pawn.can_act() and curr_pawn in get_children():
		tactics_camera.target = curr_pawn
		stage = 1


## Called by [TacticsParticipant] to initialize TacticsPlayer:
## Select a pawn & start listening to UI button presses for player actions.
func init_player() -> void:
	tactics_camera.target = get_children().front()

	var actions = {
		"Move": "_player_wants_to_move",
		"Wait": "_player_wants_to_wait",
		"Cancel": "_player_wants_to_cancel",
		"Attack": "_player_wants_to_attack",
		"Debug_next_turn": "_player_wants_to_skip_turn"
	}

	for action in actions.keys():
		ui_control.get_act(action).connect("pressed", Callable(self, actions[action]))


## Calculates where the mouse pointer actually is on the game canvas
## by casting a ray (from the camera through the mouse pointer)
## until it collides with an object, that it returns.
func _get_3d_canvas_mouse_position(collision_mask: int) -> Object:
	if ui_control.is_mouse_hovering_button():
		return null

	var _ray_length = 1_000_000
	var _camera = get_viewport().get_camera_3d()
	print(_camera)
	var _mouse_pointer_origin = get_viewport().get_mouse_position() if not is_joystick else get_viewport().size / 2

	var from = _camera.project_ray_origin(_mouse_pointer_origin)
	var to = from + _camera.project_ray_normal(_mouse_pointer_origin) * _ray_length

	var ray_query = PhysicsRayQueryParameters3D.create(from, to, collision_mask, [])
	return get_world_3d().direct_space_state.intersect_ray(ray_query).get("collider")


# --- user action inputs --- #
## Set stage as player clicks on Move
func _player_wants_to_move() -> void: 
	stage = 2


## Set stage as player clicks on Cancel
func _player_wants_to_cancel() -> void: 
	stage = 1 if stage > 1 else 0


## Set stage as player clicks on Wait
func _player_wants_to_wait() -> void: 
	curr_pawn.on_wait()
	stage = 0


## Set stage as player clicks on Next Turn
func _player_wants_to_skip_turn() -> void: 
	for pawn in get_children():
		pawn.on_wait()
	stage = 0


## Set stage as player clicks on Attack
func _player_wants_to_attack() -> void: 
	stage = 5


# --- aux stage funcs --- #
## Returns whether the pawn has been centered to tile origin already
func is_pawn_configured() -> bool:
	for pawn in get_children():
		if not pawn.configure():
			return false
	return true


## Selects the clicked pawn
func _select_hovered_pawn() -> PhysicsBody3D:
	var pawn = _get_3d_canvas_mouse_position(2)
	var tile = _get_3d_canvas_mouse_position(1) if not pawn else pawn.get_tile()
	arena.mark_hover_tile(tile)
	return pawn if pawn else tile.get_tile_occupier() if tile else null


## Selects the clicked tile
func _select_hovered_tile() -> TacticsTile:
	var pawn = _get_3d_canvas_mouse_position(2)
	var tile = _get_3d_canvas_mouse_position(1) if not pawn else pawn.get_tile()
	arena.mark_hover_tile(tile)
	return tile


# --- stages ---- #


## Controller for act() stage 1
func show_available_pawn_actions() -> void:
	curr_pawn.service.display_pawn_stats(true)
	arena.reset_all_tile_markers()
	arena.mark_hover_tile(curr_pawn.get_tile())


## Controller for act() stage 3
func show_available_movements() -> void:
	arena.reset_all_tile_markers()
	if not curr_pawn: 
		return

	tactics_camera.target = curr_pawn
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.stats.jump, get_children())
	arena.mark_reachable_tiles(curr_pawn.get_tile(), curr_pawn.stats.mp)
	stage = 3


## Controller for act() stage 6
func display_attackable_targets() -> void:
	arena.reset_all_tile_markers()
	if not curr_pawn: 
		return

	tactics_camera.target = curr_pawn
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.stats.range)
	arena.mark_attackable_tiles(curr_pawn.get_tile(), curr_pawn.stats.range)
	stage = 6


## Controller for act() stage 4
func select_new_location() -> void:
	var tile = _get_3d_canvas_mouse_position(1)
	arena.mark_hover_tile(tile)
	if Input.is_action_just_pressed("ui_accept") and tile and tile.reachable:
		curr_pawn.pathfinding_tilestack = arena.get_pathfinding_tilestack(tile)
		tactics_camera.target = tile
		stage = 4


## Controller for act() stage 7
func select_pawn_to_attack() -> void:
	curr_pawn.service.display_pawn_stats(true)
	if attackable_pawn: 
		attackable_pawn.service.display_pawn_stats(false)

	var tile = _select_hovered_tile()
	attackable_pawn = tile.get_tile_occupier() if tile else null
	if attackable_pawn: 
		attackable_pawn.service.display_pawn_stats(true)

	if Input.is_action_just_pressed("ui_accept") and tile and tile.attackable:
		tactics_camera.target = attackable_pawn
		stage = 7


## Controller for act() stage 5
func move_pawn() -> void:
	curr_pawn.service.display_pawn_stats(false)
	if curr_pawn.pathfinding_tilestack.is_empty(): 
		stage = 0 if not curr_pawn.can_act() else 1
#endregion
