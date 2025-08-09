class_name Person
extends CharacterBody2D


enum State
{
	STANDING,
	SITTING,
	DEAD
}


signal started_walking
signal arrived
signal started_exiting()
signal started_entering()
signal sat_down(chair: BusChair)
signal stood_up()
signal entered_bus(bus: Bus)
signal exited_bus(bus: Bus)


@export var nav_agent: NavigationAgent2D
@export var overlap_area: Area2D
@export var checker: bool = false
@export var sprite: Sprite2D

var checked: bool = false
var move_speed: float = 15.0
var walking: bool = false
var target_chair: BusChair
var sitting_on_chair: BusChair
var inside_bus: Bus = null:
	set(value):
		if value == null and is_instance_valid(inside_bus):
			inside_bus.people.erase(self)
		elif is_instance_valid(value) and inside_bus == null:
			value.people.append(self)
		inside_bus = value
	get: 
		return inside_bus
var last_change: int


func _ready():
	entered_bus.connect(_on_entered_bus)
	exited_bus.connect(_on_exited_bus)


func _on_entered_bus(bus: Bus):
	pass


func _on_exited_bus(bus: Bus):
	pass


func _exit_tree():
	pass


func _physics_process(delta: float) -> void:
	if walking:
		_process_walking(delta)
		if target_chair:
			_process_approach_chair()
	_process_out_of_bus_movement(delta)


func _process(delta):
	pass


func _process_walking(delta):
	var dir: Vector2 = global_position.direction_to(nav_agent.get_next_path_position())
	var speed: float = get_speed()
	velocity = dir * speed
	sprite.global_rotation = velocity.angle() + PI
	move_and_slide()
	if nav_agent.is_target_reached():
		walking = false
		arrived.emit()


func _process_approach_chair():
	if target_chair.person_sitting != null:
		target_chair = null
		walking = false
	elif global_position.distance_to(target_chair.global_position) < 3.0:
		sit_on_chair(target_chair)


func _process_out_of_bus_movement(delta):
	if inside_bus == null:
		modulate = Color.BLACK
		if Bus.player_in_bus:
			global_position.x += Bus.current_bus.current_speed*delta
	else:
		modulate = Color.WHITE
		if not Bus.player_in_bus:
			global_position.x -= Bus.current_bus.current_speed*delta

func set_destination(pos: Vector2):
	nav_agent.target_position = pos
	target_chair = null
	if not walking:
		started_walking.emit()
	walking = true
	if sitting_on_chair:
		stand_up()


func go_to_chair(chair: BusChair):
	set_destination(chair.global_position)
	target_chair = chair


func sit_on_chair(chair: BusChair):
	chair.sit_person(self)
	sat_down.emit(chair)
	global_position = chair.global_position
	sprite.global_rotation = chair.global_rotation
	sitting_on_chair = chair
	chair = null
	walking = false


func stand_up():
	sitting_on_chair.stand_up_person()
	sitting_on_chair = null
	stood_up.emit()



func do_random_bus_thing():
	if not inside_bus: return
	if randi()%2 == 0: 
		await sit_on_random_chair()
	else: 
		await walk_to_random_point()


func sit_on_random_chair():
	var chairs: Array[BusChair] = inside_bus.chairs.duplicate()
	chairs.shuffle()
	for chair: BusChair in chairs:
		if chair.person_sitting == null:
			go_to_chair(chair)
			break
	

func walk_to_random_point():
	var point = inside_bus.get_random_point()
	set_destination(point)


func get_speed():
	var speed: float = move_speed
	speed /= 1#+pow(overlap_area.get_overlapping_areas().size(),0.05)
	return speed
