class_name TacticsTileService
extends Node3D
## Helper for everything Tile related


#region: --- Props ---
## The [TacticsTile] script we append to each tile after conversion
const TILE_SRC = "res://src/tactics/tactics_tile.gd"
#endregion


#region: --- Methods ---
## Returns all the neighbouring tiles in a given radius
func get_all_neighbors(radius: float) -> Array:
	var _neighbors = []
	
	for _ray in $Neighbors.get_children():
		var _obj = _ray.get_collider()
		
		if (_obj and abs(_obj.get_position().y - get_parent().get_position().y) 
				<= radius):
			_neighbors.append(_obj)
			
	return _neighbors


## Returns the object directly above the tile
func get_object_above() -> Object:
	return $Above.get_collider()


## Node3D as parameter (tiles_obj). Will iterate over each child, converting them into a static body & attaching tile.gd script.
static func tiles_into_staticbodies(tiles_obj) -> void:
	# e.g. this function will transform 'Tiles' into the following:
	#	> Tiles:                          > Tiles:
	#		> Tile1                           > StaticBody3D (tile.gd):
	#		> Tile2                               > Tile1
	#		...                                   > CollisionShape3D
	#		> TileN   -- TRANSFORM INTO ->    > StaticBody2 (tile.gd):
	#											  > Tile2
	#											  > CollisionShape3D
	#												...
	# Useful for configuring walkeable tiles as fast as possible
	for _t in tiles_obj.get_children():
		_t.create_trimesh_collision() # make StaticBody3D child
		var _static_body = _t.get_child(0) # store SB3D child in a var
		_static_body.set_position(_t.get_position()) # give it a position
		
		_t.set_position(Vector3.ZERO) # remove MI3D node's pos
		_t.set_name("Tile") # uniformly rename MI3D nodes
		_t.remove_child(_static_body) # delete child SB3D from scene tree
		tiles_obj.remove_child(_t) # delete child MI3D from scene tree
		_static_body.add_child(_t) # append it underneath SB3D instead
		_static_body.set_script(load(TILE_SRC)) # assign tile.gd to SB3D
		
		_static_body.configure_tile() # init. tile services, disable hover, reset state
		_static_body.set_process(true) # enable _process()
		
		tiles_obj.add_child(_static_body) # append SB3D to $Tiles
#endregion
