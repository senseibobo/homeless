class_name Person
extends CharacterBody2D


@export var nav_agent: NavigationAgent2D
@export var overlap_area: Area2D

var move_speed: float = 15.0
var walking: bool = false


func set_destination(pos: Vector2):
	nav_agent.target_position = pos
	walking = true


func _physics_process(delta: float) -> void:
	if walking:
		var dir: Vector2 = global_position.direction_to(nav_agent.get_next_path_position())
		var speed: float = get_speed()
		velocity = dir * speed
		move_and_slide()
		if nav_agent.is_target_reached():
			walking = false


func get_speed():
	var speed: float = move_speed
	speed /= 1+overlap_area.get_overlapping_areas().size()
	return speed
