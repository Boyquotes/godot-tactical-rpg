extends Node
class_name TacticsPawnService
## Helper methods for the Pawn logic
## 
## Used by: [TacticsArena], [TacticsTile], [TacticsPawn]

#region: --- Props ---
var animator = null
# animation
var curr_frame: int = 0
var animation_frames: int = TacticsConfig.pawn.animation_frames # 1
#endregion


#region: --- Processing ---
#endregion

#region: --- Methods ---
## Makes pawn stats visible
func display_pawn_stats(v) -> void:
	$CharacterUI.visible = v


## Removes the Y value for a Vector3
func vector_remove_y(vector):
	return vector * Vector3(1,0,1)


## Calculates a Vector3 distance, removing the Y value from the result
func vector_distance_without_y(b, a):
	return vector_remove_y(b).distance_to(vector_remove_y(a))


## Updates the pawn health display
func update_character_health(curr_health, max_health):
	$CharacterUI/HealthLabel.text = str(curr_health)+"/"+str(max_health)


## Makes the pawn half-transparent when it's done with its round
func tint_when_unable_to_act(can_pawn_act) -> void:
	self.modulate = Color(.5, .5, .5) if not can_pawn_act else Color(1,1,1)


## Defines the current pawn animation. Called every process iteration. Depends on load_animator_sprite() method
func start_animator(movement_obj) -> void:
	if movement_obj.move_direction == Vector3(0,0,0): animator.travel("IDLE")
	elif movement_obj.is_jumping: animator.travel("JUMP")


## Aligns the pawn to the center of its tile (when drag & dropped in-editor). Returns false if no Tile is detected.
func adjust_to_center(pawn, global_transform) -> bool:
	if pawn.get_tile():
		global_transform.origin = pawn.get_tile().global_transform.origin
		return true
	return false


## Sets the Pawn's rotation
func look_at_direction(pawn, dir: Vector3) -> void:
	var _fixed_dir = dir * (
			Vector3(1,0,0) if abs(dir.x) > abs(dir.z) else Vector3(0,0,1) )
	var _angle = Vector3.FORWARD.signed_angle_to(
			_fixed_dir.normalized(), Vector3.UP) + PI
	pawn.set_rotation(Vector3.UP * _angle)


## Loads the animator
func load_animator_sprite(stats, pawn_profession) -> void:
	animator = $AnimationTree.get("parameters/playback")
	animator.start("IDLE")
	$AnimationTree.active = true
	self.texture = load(stats.sprite)
	$CharacterUI/NameLabel.text = pawn_profession


## Rotates the pawn's 2D sprite to face the camera
func rotate_sprite(global_basis) -> void:
	var _camera_forward = -get_viewport().get_camera_3d().global_basis.z
	var _scalar = global_basis.z.dot(_camera_forward)
	self.flip_h = global_basis.x.dot(_camera_forward) > 0 # <90deg
	if _scalar < -0.306: self.frame = curr_frame
	elif _scalar > 0.306: self.frame = curr_frame + 1 * animation_frames
#endregion
