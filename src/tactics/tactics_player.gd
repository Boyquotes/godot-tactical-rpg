class_name TacticsPlayer
extends Node3D
## Handles player UI interactions, 
##
## Dependencies: [TacticsArena], [TacticsCamera], [TacticsControls]
## Used by: [TacticsLevel]


#region: --- Props ---
var arena: TacticsArena = null
var tactics_camera: TacticsCamera = null
var ui_control: TacticsControls = null
var curr_pawn: TacticsPawn = null ## Currently selected pawn
var attackable_pawn: TacticsPawn = null ## Storage for an attackable pawn
var is_joystick = false ## Is the input method a controller?
var stage: int = 0 ## Controls the current stage in the pawn round process
#endregion


#region: --- Processing ---
func _process(_delta: float) -> void:
	Input.set_mouse_mode(is_joystick)
	pass

func _input(event: InputEvent) -> void:
	is_joystick = event is InputEventJoypadButton or event is InputEventJoypadMotion
	ui_control.is_joystick = is_joystick
#endregion


#region: --- Methods ---
## Called by [TacticsLevel] to initialize TacticsPlayer with the necessary nodes, 
## as well as start listening to UI button presses for player actions.
func configure(my_arena: TacticsArena, my_camera: TacticsCamera, my_control: TacticsControls):
	arena = my_arena
	tactics_camera = my_camera
	ui_control = my_control
	tactics_camera.target = get_children().front()

	ui_control.get_act("Move").connect(
			"pressed",Callable(self,"_player_wants_to_move"))
	ui_control.get_act("Wait").connect(
			"pressed",Callable(self,"_player_wants_to_wait"))
	ui_control.get_act("Cancel").connect(
			"pressed",Callable(self,"_player_wants_to_cancel"))
	ui_control.get_act("Attack").connect(
			"pressed",Callable(self,"_player_wants_to_attack"))
	ui_control.get_act("Debug_next_turn").connect(
			"pressed",Callable(self,"_player_wants_to_skip_turn"))


## Calculates where the mouse pointer actually is on the game canvas
## by casting a ray (from the camera through the mouse pointer)
## until it collides with an object, that it returns.
func _get_3d_canvas_mouse_position(collision_mask):
	if ui_control.is_mouse_hovering_button(): return
	
	var _ray_length: int = 1_000_000
	var _camera = get_viewport().get_camera_3d()
	var _mouse_pointer_origin = get_viewport().get_mouse_position() if !is_joystick else get_viewport().size/2
	
	var from = _camera.project_ray_origin(_mouse_pointer_origin)
	var to = from + _camera.project_ray_normal(_mouse_pointer_origin) * _ray_length
	
	var ray_query = PhysicsRayQueryParameters3D.create(from, to, collision_mask, [])
	return get_world_3d().direct_space_state.intersect_ray(ray_query).get("collider")


## Returns whether the player pawn can act
func can_act():
	#var pawn: TacticsPawn
	for pawn in get_children(): 
		if pawn.can_act(): return true 
	return stage > 0


## Resets all player pawns turn
func reset_turn():
	for pawn in get_children(): 
		pawn.reset_turn()


# --- user action inputs --- #
## Set stage as player clicks on Move
func _player_wants_to_move(): 
	stage = 2


## Set stage as player clicks on Cancel
func _player_wants_to_cancel(): 
	stage = 1 if stage > 1 else 0


## Set stage as player clicks on Wait
func _player_wants_to_wait(): 
	curr_pawn.do_wait()
	stage = 0


## Set stage as player clicks on Next Turn
func _player_wants_to_skip_turn(): 
	var _all_pawns = get_children()
	for _p in _all_pawns:
		_p.do_wait()
		stage = 0


## Set stage as player clicks on Attack
func _player_wants_to_attack(): 
	stage = 5


# --- aux stage funcs --- #
## Returns whether the pawn has been centered to tile origin already
func _is_pawn_centered():
	for pawn in get_children():
		if !pawn.configure():
			return false
	return true


## Selects the clicked pawn
func _select_hovered_pawn():
	var pawn = _get_3d_canvas_mouse_position(2)
	var tile = func(): 
		if !pawn:
			_get_3d_canvas_mouse_position(1)
		else:
			pawn.get_tile()
	arena.mark_hover_tile(tile)
	return pawn if pawn else tile.get_tile_occupier() if tile else null


## Selects the clicked tile
func _select_hovered_tile():
	var pawn = _get_3d_canvas_mouse_position(2)
	var tile = _get_3d_canvas_mouse_position(1) if !pawn else pawn.get_tile()
	arena.mark_hover_tile(tile)
	return tile


# --- stages ---- #
## 
func _select_pawn():
	arena.reset_all_tile_markers()
	if curr_pawn: curr_pawn.display_pawn_stats(false)
	curr_pawn = _select_hovered_pawn()
	if !curr_pawn: return
	curr_pawn.display_pawn_stats(true)
	if Input.is_action_just_pressed("ui_accept") and curr_pawn.can_act() and curr_pawn in get_children():
		tactics_camera.target = curr_pawn
		stage = 1


## 
func display_available_actions_for_pawn():
	curr_pawn.display_pawn_stats(true)
	arena.reset_all_tile_markers()
	arena.mark_hover_tile(curr_pawn.get_tile())


## 
func display_available_movements():
	arena.reset_all_tile_markers()
	if !curr_pawn: return
	tactics_camera.target = curr_pawn
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.jump_height, get_children())
	arena.mark_reachable_tiles(curr_pawn.get_tile(), curr_pawn.move_radius)
	stage = 3


## 
func display_attackable_targets():
	arena.reset_all_tile_markers()
	if !curr_pawn: return
	tactics_camera.target = curr_pawn
	arena.get_surrounding_tiles(curr_pawn.get_tile(), curr_pawn.attack_radius)
	arena.mark_attackable_tiles(curr_pawn.get_tile(), curr_pawn.attack_radius)
	stage = 6


## 
func select_new_location():
	var tile = _get_3d_canvas_mouse_position(1)
	arena.mark_hover_tile(tile) 
	if Input.is_action_just_pressed("ui_accept"):
		if tile and tile.reachable:
			curr_pawn.pathfinding_tilestack = arena.get_pathfinding_tilestack(tile)
			tactics_camera.target = tile
			stage = 4


## 
func select_pawn_to_attack():
	curr_pawn.display_pawn_stats(true)
	if attackable_pawn: attackable_pawn.display_pawn_stats(false)
	var tile = _select_hovered_tile()
	attackable_pawn = tile.get_tile_occupier() if tile else null
	if attackable_pawn: attackable_pawn.display_pawn_stats(true)
	if Input.is_action_just_pressed("ui_accept") and tile and tile.attackable:
		tactics_camera.target = attackable_pawn
		stage = 7


## 
func move_pawn():
	curr_pawn.display_pawn_stats(false)
	if curr_pawn.pathfinding_tilestack.is_empty(): 
		stage = 0 if !curr_pawn.can_act() else 1


## 
func attack_pawn(delta):
	if !attackable_pawn: curr_pawn.can_attack = false
	else:
		if !curr_pawn.do_attack(attackable_pawn, delta): return
		attackable_pawn.display_pawn_stats(false)
		tactics_camera.target = curr_pawn
	attackable_pawn = null
	stage = 0 if !curr_pawn.can_act() else 1


# --- camera --- #
## 
func move_camera():
	var h = -Input.get_action_strength("camera_left")+Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward")-Input.get_action_strength("camera_backwards")
	tactics_camera.move_camera(h, v, is_joystick)


## 
func camera_rotation():
	if Input.is_action_just_pressed("camera_rotate_left"): tactics_camera.y_rot -= 90
	if Input.is_action_just_pressed("camera_rotate_right"): tactics_camera.y_rot += 90
	if Input.is_action_just_pressed("camera_free_look"): 
		tactics_camera.in_free_look = true


## 
func act(delta):
	move_camera()
	camera_rotation()
	ui_control.set_visibility_of_actions_menu(stage in [1,2,3,5,6], curr_pawn)
	match stage:
		0: _select_pawn()
		1: display_available_actions_for_pawn()
		2: display_available_movements()
		3: select_new_location()
		4: move_pawn()
		5: display_attackable_targets()
		6: select_pawn_to_attack()
		7: attack_pawn(delta)


## 
func post_configure():
	return _is_pawn_centered()
#endregion
