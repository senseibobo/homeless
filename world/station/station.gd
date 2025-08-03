class_name Station
extends Node2D


static var current_station: Station

var waited_time: float = 0.0
var spawned_bus: bool = false


@export var bus_scene: PackedScene 


func _ready():
	current_station = self
	


func _process(delta):
	if Bus.current_bus:
		global_position.x += Bus.current_bus.current_speed*delta
		if global_position.x > 120:
			queue_free()
	else:
		waited_time += delta
		if waited_time > 5.0:
			spawn_bus()
			waited_time -= 10.0


func spawn_bus():
	spawned_bus = true
	var bus: Bus = bus_scene.instantiate()
	get_tree().current_scene.add_child(bus)
	bus.current_speed = bus.max_speed
	var a: float = bus.current_speed / bus.deceleration_time
	var start_x: float = -0.5*bus.get_s_from_v0at(bus.current_speed, a, bus.deceleration_time)
	print(start_x)
	bus.global_position = Vector2(start_x, -3.0)
	await bus.stop_driving()
	bus.do_driving_loop()
