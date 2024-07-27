class_name World
extends Node3D
## 

#region: --- Methods ---
## Calculates where the mouse pointer actually is on the game canvas
## by casting a ray (from the camera through the mouse pointer)
## until it collides with an object, that it returns.
func _get_pointer_collider(camera, ray_length: int, collision_mask: int, is_joystick: bool) -> Object:
	var _mouse_pointer_origin = get_viewport().get_mouse_position() if not is_joystick else get_viewport().size / 2

	var from = _camera.project_ray_origin(_mouse_pointer_origin)
	var to = from + _camera.project_ray_normal(_mouse_pointer_origin) * ray_length

	var ray_query = PhysicsRayQueryParameters3D.create(from, to, collision_mask, [])
	return get_world_3d().direct_space_state.intersect_ray(ray_query).get("collider")


#endregion
