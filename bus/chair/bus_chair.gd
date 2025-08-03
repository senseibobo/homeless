class_name BusChair
extends Area2D


static var chairs: Array[BusChair]

var mouse_over: bool = false
var person_sitting: Person
var bus: Bus
@export var edge_chair: bool = false


func _ready():
	bus = get_parent()
	bus.chairs.append(self)
	chairs.append(self)
	visible = false


func _exit_tree() -> void:
	chairs.erase(self)


func _on_mouse_entered() -> void:
	print("AA")
	if person_sitting: return
	Player.instance.disable_mouse_input()
	visible = true
	mouse_over = true


func _on_mouse_exited() -> void:
	Player.instance.enable_mouse_input()
	visible = false
	mouse_over = false


func sit_person(person: Person):
	person_sitting = person


func stand_up_person():
	person_sitting = null


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if mouse_over and visible and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Player.instance.go_to_chair(self)
	elif event is InputEventMouseMotion:
		var size: Vector2 = Vector2(6,4)
		if Rect2(global_position - size/2, size).has_point(get_global_mouse_position()):
			if not mouse_over:
				_on_mouse_entered()
		else:
			if mouse_over:
				_on_mouse_exited()
		
