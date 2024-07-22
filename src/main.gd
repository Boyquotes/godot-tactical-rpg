extends Control


#region: --- Props ---
@onready var hud: Control = $HUD
@onready var menu: Control = $Menu
@onready var main_3d: Node3D = $Main3D
var level_instance: TacticsLevel
#endregion


#region: --- Processing ---
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass
#endregion


#region: --- Signals ---
func _on_load_map_0_pressed() -> void:
	load_level("test")
#endregion


#region: --- Methods ---
## Unloads the current level instance
func unload_level():
	if is_instance_valid(level_instance):
		level_instance.queue_free()
	level_instance = null

## Loads the current level instance -- clears existing level in the process
func load_level(level_name: String):
	unload_level()
	var level_path := "res://assets/maps/%s_level.tscn" % level_name
	main_3d.add_child(load(level_path).instantiate())
#endregion
