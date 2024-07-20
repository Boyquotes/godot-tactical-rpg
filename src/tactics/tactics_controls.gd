class_name TacticsControls
extends Control
## Handles __________
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
func get_act(action: String = ""):
	if action == "": 
		return $HBox/Actions
	return $HBox/Actions.get_node(action)


func is_mouse_hovering_button():
	if $HBox/Actions.visible:
		for action in $HBox/Actions.get_children():
			if action.get_global_rect().has_point(get_viewport().get_mouse_position()): 
				return true
	return false


func set_visibility_of_actions_menu(v, p):
	if !$HBox/Actions.visible: $HBox/Actions/Move.grab_focus()
	$HBox/Actions.visible = v and p.can_act()
	if !p: return
	$HBox/Actions/Move.disabled = !p.can_move
	$HBox/Actions/Attack.disabled = !p.can_attack
#endregion
