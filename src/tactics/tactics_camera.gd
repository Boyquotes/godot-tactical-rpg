class_name TacticsCamera
extends CharacterBody3D
## Handles camera movement features
##
## There are several camera movement methods:[br]
## - [code]rotate_camera[/code]: "Cardinal Points" mode [i](Q,E)[/i][br]
## - [code]move_camera[/code]: "Panning" mode [i](W,A,S,D)[/i][br]
## - [code]free_look[/code]: "Free Look" mode [i](MMB)[/i][br]
## - [code]follow[/code]: "Focus" mode [i](programmatically called)[/i][br][br]
## Used by: [TacticsLevel], [TacticsPlayer]


#region: --- Props ---
const MOVE_SPEED: int = 16
const ROT_SPEED: int = 10

@onready var t_pivot: Node3D = $TwistPivot
@onready var p_pivot: Node3D = $TwistPivot/PitchPivot
var target = null
# --- rotation ---
var x_rot: int = -30
var y_rot: int = -45
var z_rot: int = 0
# --- free look ---
var in_free_look := false
var twist_input := 0.0 # stores how much horizontal movement happens every frame
var pitch_input := 0.0 # stores how much vertical movement happens every frame
#endregion


#region: --- Processing ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: # free_look logic
		if in_free_look:
			twist_input = - event.relative.x * (0.025 * ROT_SPEED)
			pitch_input = - event.relative.y * (0.025 * ROT_SPEED)
	
	if Input.is_action_just_released("camera_free_look"): 
		in_free_look = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _process(delta) -> void:
	if in_free_look: 
		free_look(delta) # unless in "free look" mode
	else: 
		_rotate_camera(delta) # default to active "cardinal points" view
	_follow()
#endregion


#region: --- Methods ---
# Camera Modes
## Panning (WASD)   ||   h = left/right angle, v = up/down angle
func move_camera(h: float, v: float, joystick: bool) -> void:
	if !joystick and h == 0 and v == 0 or target: 
		return
	
	var angle = (atan2(-h, v)) + t_pivot.get_rotation().y
	var dir = Vector3.FORWARD.rotated(Vector3.UP, angle)
	var vel = dir * MOVE_SPEED
	if joystick: vel = vel * sqrt(h*h + v*v)
	
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity


## Default "cardinal points" view   ||   fixed isometric rotation
func _rotate_camera(delta) -> void:
	var curr_t = t_pivot.get_rotation() ## Current twist
	var curr_p = p_pivot.get_rotation() ## Current pitch
	var dst_t = Vector3(deg_to_rad(x_rot), deg_to_rad(y_rot), 0)
	var dst_p = Vector3(0, 0, z_rot)
	
	t_pivot.set_rotation(curr_t.lerp(dst_t, ROT_SPEED*delta))
	p_pivot.set_rotation(curr_p.lerp(dst_p, ROT_SPEED*delta))


## Is this 3D or what? Fancy "free look" camera mode (MMB).
func free_look(delta) -> void:
	if Input.get_current_cursor_shape() == Input.CURSOR_ARROW:
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
	
	t_pivot.rotate_y(twist_input * delta)
	p_pivot.rotate_x(pitch_input * delta)
	p_pivot.rotation.x = clamp(p_pivot.rotation.x, deg_to_rad(-60), 
			deg_to_rad(30))
	
	twist_input = 0.0
	pitch_input = 0.0


## Focus mode   ||   provided a target, camera locks onto it
func _follow() -> void:
	if !target: return
	
	var from = global_transform.origin
	var to = target.global_transform.origin
	var vel = (to-from)*MOVE_SPEED/4
	
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	vel = velocity
	if from.distance_to(to) <= 0.25: 
		target = null
#endregion
