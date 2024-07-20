class_name TacticsTile
extends StaticBody3D
## Handles tiles, hover colors, tile state, pathfinding.
## 
## Dependencies: [TacticsTileService] [br]
## Used by: [TacticsArena]


#region: --- Props ---
var tile_services: Resource = load("res://assets/tscn/tactics/tactics_tile_raycasting.tscn")
# ----- tile state -----
var reachable: bool = false
var attackable: bool = false
var hover: bool = false
# ---- pathfinding -----
var pf_root: TacticsTile ## Pathfinding starting point.[br]Used by [TacticsArena]
var pf_distance: float ## The distance to cover.[br]Used by [TacticsArena]
# ------- colors -------
var hover_mat:  StandardMaterial3D = TacticsConfig.material.hover
var reachable_mat: StandardMaterial3D = TacticsConfig.material.reachable
var hover_reachable_mat: StandardMaterial3D = TacticsConfig.material.reachable_hover
var attackable_mat: StandardMaterial3D = TacticsConfig.material.attackable
var hover_attackable_mat: StandardMaterial3D = TacticsConfig.material.hover_attackable
#endregion


#region: --- Processing ---
func _process(_delta) -> void:
	$Tile.visible = attackable or reachable or hover
	
	match hover:
		true:
			if reachable: $Tile.material_override = hover_reachable_mat
			elif attackable: $Tile.material_override = hover_attackable_mat
			else: $Tile.material_override = hover_mat
		false:
			if reachable: $Tile.material_override = reachable_mat
			elif attackable: $Tile.material_override = attackable_mat
#endregion


#region: --- Methods ---
# Getters
## Returns all 4 directly adjacent tiles
func get_neighbors(radius: float) -> Array:
	return $RayCasting.get_all_neighbors(radius)


## Returns any collider directly (<=1m) above
func get_tile_occupier() -> Object:
	return $RayCasting.get_object_above()


## Return whether target tile is occupied
func is_taken() -> bool:
	return get_tile_occupier() != null


# Setters
## Resets the tile's markers (pf_root, pf_distance, reachable, attackable)
func reset_markers() -> void:
	pf_root = null
	pf_distance = 0
	reachable = false
	attackable = false


## Initializes tile (disable hover, instantiate TileServices & reset state)
func configure_tile() -> void:
	hover = false
	add_child(tile_services.instantiate())
	reset_markers()
#endregion
