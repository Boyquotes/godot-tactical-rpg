class_name TacticsArena
extends Node3D
## Tile config & sorting, neighbours, hover & reach UI overlay, pathfinding and targeting utilities.
## 
## Dependencies: [TacticsPawnService], [TacticsTileService], [TacticsTile][br]
## Used by: [TacticsLevel]


#region: --- Methods: Utilities ---
## Clears all tiles of their markers (pf_root, pf_distance, reachable, attackable)
func reset_all_tile_markers():
	for t in $Tiles.get_children():
		t.reset_markers()


## Configures all tiles, rendering them visible and converting them into StaticBody3D.
func configure_tiles():
	$Tiles.visible = true
	TacticsTileService.tiles_into_staticbodies($Tiles)
#endregion


#region: --- Methods: Pathfinding --- 
## Returns the array of (map) coordinates for all tiles towards your destination.[br]
## e.g. [code][(-2.5, 2.51, -1.5), (-3.5, 3.01, -1.5), (-4.5, 3.51, -1.5), (-4.5, 2.51, -0.5), (-4.5, 2.51, 0.5), (-4.5, 2.51, 1.5)][/code]
func get_pathfinding_tilestack(to: TacticsTile) -> Array:
	var _path_tiles_stack = []
	
	while to:
		to.hover = true
		_path_tiles_stack.push_front(to.global_transform.origin)
		to = to.pf_root
		
	return _path_tiles_stack


## Returns the nearest target's unoccupied adjacent [TacticsTile].
func get_nearest_target_adjacent_tile(
		pawn: TacticsPawn, target_pawns: Array) -> TacticsTile:
	var _nearest_target = null
	
	for _p in target_pawns:
		if _p.stats.curr_health <= 0: continue
		for _n in _p.get_tile().get_neighbors(pawn.stats.jump):
			if not _nearest_target or _n.pf_distance < _nearest_target.pf_distance:
				if _n.pf_distance > 0 and not _n.is_taken():
					_nearest_target = _n
	
	while _nearest_target and not _nearest_target.reachable: 
		_nearest_target = _nearest_target.pf_root
	
	if _nearest_target:
		return _nearest_target 
	else:
		return pawn.get_tile()


## Returns the weakest attackable target [TacticsPawn].
func get_weakest_attackable_pawn(pawn_arr: Array) -> TacticsPawn:
	var _weakest = null
	
	for _p in pawn_arr:
		if not _weakest or _p.stats.curr_health < _weakest.stats.curr_health:
			if _p.stats.curr_health > 0 and _p.get_tile().attackable:
				_weakest = _p
	
	return _weakest
#endregion


#region: --- Methods: Tile Overlays ---
## Returns the array of traversable tiles surrounding the root tile. Includes tiles occupied by allies on the map (if provided).[br]Uses [TacticsTile]
func get_surrounding_tiles(
		root_tile: TacticsTile, radius: float, allies_on_map: Array = []):
	var _tiles = [root_tile]
	
	while not _tiles.is_empty():
		var _curr_tile: TacticsTile = _tiles.pop_front()
		var _add_to_tiles_list = func _add(_neighbor):
			_neighbor.pf_root = _curr_tile
			_neighbor.pf_distance = _curr_tile.pf_distance + 1
			_tiles.push_back(_neighbor)
		
		for _neighbor in _curr_tile.get_neighbors(radius):
			if not _neighbor.pf_root and _neighbor != root_tile:
				#if not (neighbor.is_taken() and allies_arr and not neighbor.get_tile_occupier() in allies_arr):
				if not _neighbor.is_taken():
					_add_to_tiles_list.call(_neighbor)
				elif not (allies_on_map.size() > 0):
					if not (_neighbor.get_tile_occupier() in allies_on_map):
						_add_to_tiles_list.call(_neighbor)


## Marks tile as hovered, resets all other hovered tiles.
func mark_hover_tile(tile: TacticsTile):
	for _t in $Tiles.get_children():
		_t.hover = false
	
	if tile:
		tile.hover = true


## Marks tiles that can be reached by the pawn.
func mark_reachable_tiles(root: TacticsTile, distance: float):
	for _t in $Tiles.get_children():
		var _has_dist = _t.pf_distance > 0
		var _reachable = _t.pf_distance <= distance
		var _not_taken = not _t.is_taken()
		var _is_root = _t == root
		
		_t.reachable = (_has_dist and _reachable and _not_taken) or _is_root


## Marks tiles that can be attacked by the pawn.
func mark_attackable_tiles(root: TacticsTile, distance: float):
	for _t in $Tiles.get_children():
		var _has_dist = _t.pf_distance > 0
		var _reachable = _t.pf_distance <= distance
		var _is_root = _t == root
		
		_t.attackable = _has_dist and _reachable or _is_root
#endregion
