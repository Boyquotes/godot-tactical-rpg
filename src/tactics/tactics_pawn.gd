class_name TacticsPawn
extends CharacterBody3D
## Handles Pawn round, movement, stats
##
## Used by: [TacticsLevel]


#region: --- Props ---
@export var pawn_class: TacticsPawnService.PAWN_CLASSES
@export var pawn_strategy: TacticsPawnService.PAWN_STRATEGIES
@export var pawn_name: String = "Trooper" # migrate to character class
#@export var starting_tile: TacticsTile
# ----- public -----
# local
var can_move := true ## Can the pawn move?
var can_attack := true ## Can the pawn attack?
# TRANSITION TO: mp
var move_radius ## The radius the pawn can move
# TRANSITION TO: mp/2
var jump_height ## The block height the pawn can jump
# TRANSITION TO: range
var attack_radius ## The radius the pawn can attack
# attack_power
var attack_power ## The amount of damage a basic attack does
# SEND
var curr_health: int = 100 ## Pawn's current health
var pathfinding_tilestack := [] ## An array of tile coordinates. See [TacticsTile]
# ----- private -----
var _max_health: int = 100
# configurable stats
var _walk_speed: int = TacticsConfig.pawn.base_walk_speed # 16
var _animation_frames: int = TacticsConfig.pawn.animation_frames # 1
var _min_height_to_jump: int = TacticsConfig.pawn.min_height_to_jump # 1
var _gravity_strength: int = TacticsConfig.pawn.gravity_strength # 7
var _min_time_for_attack: int = TacticsConfig.pawn.min_time_for_attack # 1
# animation
var _curr_frame: int = 0
var _animator = null
# pathfinding
var _move_direction := Vector3(0,0,0)
var _is_jumping := false
var _gravity := Vector3.ZERO
var _wait_delay: float = 0.0
#endregion


#region: --- Processing ---
func _ready() -> void:
	_load_stats()
	_load_animator_sprite()
	display_pawn_stats(false)


func _process(delta: float) -> void:
	_rotate_pawn_sprite()
	_move_along_path(delta)
	_start_animator()
	_tint_when_unable_to_act()
	$CharacterStats/HealthLabel.text = str(curr_health)+"/"+str(_max_health)	
#endregion


#region: --- Methods ---
## Returns the Pawn's Tile (as a StaticBody3D)
func get_tile() -> Object:
	return $Tile.get_collider()


## Rotates the pawn's 2D sprite to face the camera
func _rotate_pawn_sprite() -> void:
	var _camera_forward = -get_viewport().get_camera_3d().global_basis.z
	var _scalar = global_basis.z.dot(_camera_forward)
	$Character.flip_h = global_basis.x.dot(_camera_forward) > 0 # <90deg
	if _scalar < -0.306: $Character.frame = _curr_frame
	elif _scalar > 0.306: $Character.frame = _curr_frame + 1 * _animation_frames


## Sets the Pawn's rotation
func _look_at_direction(dir: Vector3) -> void:
	var _fixed_dir = dir * (
			Vector3(1,0,0) if abs(dir.x) > abs(dir.z) else Vector3(0,0,1) )
	var _angle = Vector3.FORWARD.signed_angle_to(
			_fixed_dir.normalized(), Vector3.UP) + PI
	set_rotation(Vector3.UP * _angle)


## Aligns the pawn to the center of its tile (when drag & dropped in-editor). Returns false if no Tile is detected.
func _adjust_to_center() -> bool:
	if get_tile():
		global_transform.origin = get_tile().global_transform.origin
		return true
	return false


## Loads the animator
func _load_animator_sprite() -> void:
	_animator = $Character/AnimationTree.get("parameters/playback")
	_animator.start("IDLE")
	$Character/AnimationTree.active = true
	$Character.texture = TacticsPawnService.get_pawn_sprite(pawn_class)
	$CharacterStats/NameLabel.text = pawn_name+", the "+String(TacticsPawnService.PAWN_CLASSES.keys()[pawn_class])


## Defines the current pawn animation. Called every process iteration. Depends on _load_animator_sprite() method
func _start_animator() -> void:
	if _move_direction == Vector3(0,0,0): _animator.travel("IDLE")
	elif _is_jumping: _animator.travel("JUMP")


## Triggers movement and animates pawn along the tilestack path (if pawn can move)
func _move_along_path(delta: float) -> void:
	if not pathfinding_tilestack.is_empty(): 
		if not can_move: return
		if _move_direction == Vector3(0,0,0): 
			_move_direction = pathfinding_tilestack.front() - global_transform.origin

		if _move_direction.length() > 0.5:

			_look_at_direction(_move_direction)
			var _p_velocity = _move_direction.normalized()
			var _curr_speed = _walk_speed

			# apply jump
			if _move_direction.y > _min_height_to_jump: 
				_curr_speed = clamp(abs(_move_direction.y)*2.3, 3, INF)
				_is_jumping = true

			# fall or move to the edge before falling
			elif _move_direction.y < -_min_height_to_jump:
				if TacticsPawnService.vector_distance_without_y(pathfinding_tilestack.front(), global_transform.origin) <= 0.2:
					_gravity += Vector3.DOWN * delta * _gravity_strength
					_p_velocity = (pathfinding_tilestack.front()-global_transform.origin).normalized()+_gravity
				else:
					_p_velocity = TacticsPawnService.vector_remove_y(_move_direction).normalized()

			set_velocity(_p_velocity*_curr_speed)
			set_up_direction(Vector3.UP)
			move_and_slide()
			var _v = _p_velocity
			if global_transform.origin.distance_to(pathfinding_tilestack.front()) >= 0.15: return

		pathfinding_tilestack.pop_front()
		_move_direction = Vector3(0,0,0)
		_is_jumping = false
		_gravity = Vector3.ZERO
		can_move = pathfinding_tilestack.size() > 0
		if not can_move:
			_adjust_to_center()

## Used when the user input is "Wait" -- effectively ends current pawn's turn
func do_wait() -> void:
	can_move = false
	can_attack = false


## Debug feature: ends all pawns turn
func debug_wait() -> void:
	can_move = false
	can_attack = false


## Faces target & applies damage. Returns false if attack hasn't yet finished
func do_attack(target_pawn: TacticsPawn, delta: float) -> bool:
	_look_at_direction(target_pawn.global_transform.origin-global_transform.origin)
	if can_attack and _wait_delay > _min_time_for_attack / 4.0: 
		target_pawn.curr_health = clamp(target_pawn.curr_health-attack_power, 0, INF)
		can_attack = false
	if _wait_delay < _min_time_for_attack:
		_wait_delay += delta
		return false
	_wait_delay = 0.0
	return true


## Resets the pawn's turn state
func reset_turn() -> void:
	can_move = true
	can_attack = true	


## Returns whether the pawn can act this round
func can_act() -> bool:
	return (can_move or can_attack) and curr_health > 0


## Returns the pawn stats
func _load_stats() -> void:
	move_radius = TacticsPawnService.get_pawn_move_radius(pawn_class)
	jump_height = TacticsPawnService.get_pawn_jump_height(pawn_class)
	attack_radius = TacticsPawnService.get_pawn_attack_radius(pawn_class)
	attack_power = TacticsPawnService.get_pawn_attack_power(pawn_class)
	_max_health = TacticsPawnService.get_pawn_health(pawn_class)
	curr_health = _max_health


## Makes the pawn half-transparent when it's done with its round
func _tint_when_unable_to_act() -> void:
	$Character.modulate = Color(.5, .5, .5) if not can_act() else Color(1,1,1)


## Makes pawn stats visible
func display_pawn_stats(v) -> void:
	$CharacterStats.visible = v


## Configures pawn, making sure it is centered on its tile
func configure() -> bool:
	return _adjust_to_center()
#endregion
