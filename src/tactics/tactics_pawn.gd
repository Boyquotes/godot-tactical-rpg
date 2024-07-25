class_name TacticsPawn
extends CharacterBody3D
## Handles Pawn round, movement, stats
##
## Used by: [TacticsLevel]


#region: --- Props ---
# ----- public -----
var service: TacticsPawnService
# stats
@export var override_name := "" # TODO
var stats: Stats
var pawn_profession: String
var can_move := true ## Can the pawn move?
var can_attack := true ## Can the pawn attack?
# pathfinding
var pathfinding_tilestack := [] ## An array of tile coordinates. See [TacticsTile]
var movement_obj = {
	"move_direction": Vector3(0,0,0),
	"is_jumping": false,
}
var _gravity := Vector3.ZERO
var _wait_delay: float = 0.0
# movement & physics
var _walk_speed: int = TacticsConfig.pawn.base_walk_speed # 16
var _min_height_to_jump: int = TacticsConfig.pawn.min_height_to_jump # 1
var _gravity_strength: int = TacticsConfig.pawn.gravity_strength # 7
var _min_time_for_attack: int = TacticsConfig.pawn.min_time_for_attack # 1
#endregion


#region: --- Processing ---
func _ready() -> void:
	stats =  $Profession/Stats
	pawn_profession = $Profession/Stats.profession
	service = $Character
	service.load_animator_sprite(stats, pawn_profession)
	service.display_pawn_stats(false)


func _process(delta: float) -> void:
	service.rotate_sprite(global_basis)
	_move_along_path(delta)
	service.start_animator(movement_obj)
	service.tint_when_unable_to_act(can_act())
	service.update_character_health(stats.curr_health, stats.max_health)
#endregion


#region: --- Methods ---
## Returns the Pawn's Tile (as a StaticBody3D)
func get_tile() -> Object:
	return $Tile.get_collider()


## Returns whether the pawn can act this round
func can_act() -> bool:
	return (can_move or can_attack) and stats.curr_health > 0


## Configures pawn, making sure it is centered on its tile
func configure() -> bool:
	return service.adjust_to_center(self, global_transform)


## Resets the pawn's turn state
func reset_turn() -> void:
	can_move = true
	can_attack = true

## Used when the user input is "Wait" -- effectively ends current pawn's turn
func button_wait() -> void:
	can_move = false
	can_attack = false


## Debug feature: ends all pawns turn
func button_wait_all() -> void:
	can_move = false
	can_attack = false


## Faces target & applies damage. Returns false if attack hasn't yet finished
func button_attack(target_pawn: TacticsPawn, delta: float) -> bool:
	service.look_at_direction(self, target_pawn.global_transform.origin-global_transform.origin)
	if can_attack and _wait_delay > _min_time_for_attack / 4.0: 
		target_pawn.stats.curr_health = clamp(target_pawn.stats.curr_health-stats.attack_power, 0, INF)
		can_attack = false
	if _wait_delay < _min_time_for_attack:
		_wait_delay += delta
		return false
	_wait_delay = 0.0
	return true


## Triggers movement and animates pawn along the tilestack path (if pawn can move)
func _move_along_path(delta: float) -> void:
	if not pathfinding_tilestack.is_empty(): 
		if not can_move: return
		
		if movement_obj.move_direction == Vector3(0,0,0): 
			movement_obj.move_direction = pathfinding_tilestack.front() - global_transform.origin

		if movement_obj.move_direction.length() > 0.5:
			service.look_at_direction(self, movement_obj.move_direction)
			var _p_velocity = movement_obj.move_direction.normalized()
			var _curr_speed = _walk_speed

			# apply jump
			if movement_obj.move_direction.y > _min_height_to_jump: 
				_curr_speed = clamp(abs(movement_obj.move_direction.y)*2.3, 3, INF)
				movement_obj.is_jumping = true

			# fall or move to the edge before falling
			elif movement_obj.move_direction.y < -_min_height_to_jump:
				if service.vector_distance_without_y(pathfinding_tilestack.front(), global_transform.origin) <= 0.2:
					_gravity += Vector3.DOWN * delta * _gravity_strength
					_p_velocity = (pathfinding_tilestack.front()-global_transform.origin).normalized()+_gravity
				else:
					_p_velocity = service.vector_remove_y(movement_obj.move_direction).normalized()

			set_velocity(_p_velocity*_curr_speed)
			set_up_direction(Vector3.UP)
			move_and_slide()
			var _v = _p_velocity
			if global_transform.origin.distance_to(pathfinding_tilestack.front()) >= 0.15: return

		pathfinding_tilestack.pop_front()
		movement_obj.move_direction = Vector3(0,0,0)
		movement_obj.is_jumping = false
		_gravity = Vector3.ZERO
		can_move = pathfinding_tilestack.size() > 0
		if not can_move:
			service.adjust_to_center(self, global_transform)
#endregion
