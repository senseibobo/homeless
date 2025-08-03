class_name Player
extends Person


static var instance: Player
var mouse_input: bool = true

func _ready():
	instance = self


func _exit_tree():
	if instance == self: instance = null


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_input:
			set_destination(get_global_mouse_position())


func enable_mouse_input():
	mouse_input = true
	
	
func disable_mouse_input():
	mouse_input = false
