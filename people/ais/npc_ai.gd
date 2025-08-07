class_name NpcAi
extends PersonAi


var waiting_stations: int = randi()%6
var last_random_bus_thing: int = 0

func start():
	if person.sitting_on_chair != null:
		state = State.SITTING
	else:
		state = State.STANDING
	
	if person.inside_bus:
		exit_bus_loop()
	else:
		enter_bus_loop()


func _process(delta):
	#print(State.keys()[state])
	person.state_label.text = State.keys()[state]
	if state in [State.STANDING, State.SITTING] and last_random_bus_thing + 10000 < Time.get_ticks_msec() and person.inside_bus != null:
		last_random_bus_thing = Time.get_ticks_msec()
		person.do_random_bus_thing()


func _on_entered_bus(bus: Bus):
	if not is_instance_valid(bus):
		breakpoint
	super(bus)
	exit_bus_loop()


func _on_exited_bus(bus: Bus):
	super(bus)
	enter_bus_loop()


func exit_bus_loop():
	var bus: Bus = person.inside_bus
	waiting_stations = randi()%6 + 1
	while waiting_stations > 0:
		await bus.started_decelerating
		waiting_stations -= 1
	person.exit_bus(bus)
	await person.exited_bus


func enter_bus_loop():
	var bus: Bus = Bus.current_bus
	waiting_stations = randi()%6 + 1
	while waiting_stations > 0:
		await bus.started_decelerating
		waiting_stations -= 1
	person.enter_bus()
	await person.entered_bus
	exit_bus_loop()
