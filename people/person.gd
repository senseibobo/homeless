class_name Person
extends CharacterBody2D


@export var nav_agent: NavigationAgent2D
@export var overlap_area: Area2D

@export var ai: PersonAi

@export var checker: bool = false
var checked: bool = false
var move_speed: float = 15.0
var walking: bool = false
var target_chair: BusChair
var sitting_on_chair: BusChair
var inside_bus: Bus = null


func _ready():
	pass


func _init_ai():
	if ai:
		ai = ai.duplicate()
		ai.init(self)


func _process(delta: float) -> void:
	if ai:
		ai._process(delta)


func _physics_process(delta: float) -> void:
	if walking:
		var dir: Vector2 = global_position.direction_to(nav_agent.get_next_path_position())
		var speed: float = get_speed()
		velocity = dir * speed
		global_rotation = velocity.angle() + PI
		move_and_slide()
		if nav_agent.is_target_reached():
			walking = false
		if target_chair:
			if target_chair.person_sitting != null:
				target_chair = null
				walking = false
			if global_position.distance_to(target_chair.global_position) < 3.0:
				sit_on_chair(target_chair)
				


func set_destination(pos: Vector2):
	nav_agent.target_position = pos
	target_chair = null
	walking = true
	if sitting_on_chair:
		sitting_on_chair.stand_up_person()
		sitting_on_chair = null


func go_to_chair(chair: BusChair):
	set_destination(chair.global_position)
	target_chair = chair


func sit_on_chair(chair: BusChair):
	chair.sit_person(self)
	global_position = chair.global_position
	global_rotation = chair.global_rotation
	sitting_on_chair = chair
	chair = null
	walking = false

func get_speed():
	var speed: float = move_speed
	speed /= 1+overlap_area.get_overlapping_areas().size()
	return speed
