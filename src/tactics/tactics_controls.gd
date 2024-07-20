class_name TacticsControls
extends Control
## Handles UI elements for the Tactics systems
##
## Used by: [TacticsLevel]

#region: --- Props ---
@onready var layout_xbox = load("res://assets/textures/ui/labels/controls-ui-xbox.png")
@onready var layout_pc = load("res://assets/textures/ui/labels/controls-ui.png")
var is_joystick = false
#endregion


#region: --- Processing ---
func _process(_delta):
	if is_joystick: 
		$HBox/VBox/ControllerHints.texture = layout_xbox
	else: 
		$HBox/VBox/ControllerHints.texture = layout_pc
#endregion


#region: --- Methods ---
## Takes a node name as parameter and returns a [Button]
func get_act(action: String = "") -> Button:
	if action == "": 
		return $HBox/Actions
	return $HBox/Actions.get_node(action)


## Returns whether [VBoxContainer] "Actions"' children are currently hovered
func is_mouse_hovering_button() -> bool:
	if $HBox/Actions.visible:
		for action in $HBox/Actions.get_children():
			if action.get_global_rect().has_point(get_viewport().get_mouse_position()): 
				return true
	return false


## Makes action menu visible or hidden based on provided pawn's state
func set_actions_menu_visibility(v: bool, p: TacticsPawn) -> void:
	if !$HBox/Actions.visible: 
		$HBox/Actions/Move.grab_focus()
	$HBox/Actions.visible = v and p.can_act()
	if !p: 
		return
	
	$HBox/Actions/Move.disabled = !p.can_move
	$HBox/Actions/Attack.disabled = !p.can_attack
#endregion
