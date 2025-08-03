class_name BusDoor
extends StaticBody2D


enum OpenSide
{
	LEFT,
	RIGHT
}

@export var open_side: OpenSide = OpenSide.LEFT

var tween: Tween

func _ready():
	var bus: Bus = get_parent()
	if bus:
		bus.open_doors.connect(open)
		bus.close_doors.connect(close)


func open():
	if tween and tween.is_running(): await tween.finished
	var dir: int = -1 if open_side == OpenSide.LEFT else 1
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position:y", position.y - 2, 0.2)
	tween.tween_property(self, "position:x", position.x + 10 * dir, 0.45)


func close():
	if tween and tween.is_running(): await tween.finished
	var dir: int = -1 if open_side == OpenSide.LEFT else 1
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position:x", position.x - 10 * dir, 0.45)
	tween.tween_property(self, "position:y", position.y + 2, 0.2)
