class_name PersonAi
extends Resource


signal go_to_point(point: Vector2)
signal go_to_chair(chair: BusChair)
signal go_to_check_person(person: Person)


enum State
{
	STANDING,
	SITTING,
	GOING_TO_CHAIR,
	GOING_TO_EXIT,
	GOING_TO_ENTER
}


var state: State
var person: Person


func init(person: Person):
	self.person = person
	person.entered_bus.connect(_on_entered_bus)
	person.sat_down.connect(_on_sat_down)
	person.stood_up.connect(_on_stood_up)
	person.exited_bus.connect(_on_exited_bus)
	person.started_entering.connect(_on_started_entering)
	person.started_exiting.connect(_on_started_exiting)


func _on_entered_bus(bus: Bus):
	pass


func _on_exited_bus(bus: Bus):
	pass


func _on_sat_down(chair: BusChair):
	state = State.SITTING


func _on_stood_up():
	state = State.STANDING


func _on_started_entering():
	state = State.GOING_TO_ENTER


func _on_started_exiting():
	state = State.GOING_TO_EXIT


func _process(delta):
	pass


func start():
	pass
