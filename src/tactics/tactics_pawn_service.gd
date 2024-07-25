extends Node
class_name TacticsPawnService
## Helper & connector methods for the Pawn logic
## 
## Used by: [TacticsArena], [TacticsTile], [TacticsPawn]

#region: --- Props ---
#endregion

#region: --- Methods ---
static func vector_remove_y(vector):
	return vector * Vector3(1,0,1)

static func vector_distance_without_y(b, a):
	return vector_remove_y(b).distance_to(vector_remove_y(a))
#endregion
