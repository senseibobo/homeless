class_name Station
extends Node2D


static var current_station: Station

var waited_time: float = 0.0
var spawned_bus: bool = false


@export var bus_scene: PackedScene 
@export var spawn_positions_node: Node2D
@export var npc_scene: PackedScene


func _ready():
	current_station = self
	await get_tree().create_timer(0.05).timeout
	for i in spawn_positions_node.get_child_count():
		if randi()%100 < 80:
			var npc: Npc = spawn_npc(spawn_positions_node.get_child(i).global_position)
			if randi()%100 < 30:
				npc.enter_bus()


func _exit_tree():
	current_station = null


func spawn_npc(pos: Vector2):
	var npc = npc_scene.instantiate()
	get_tree().current_scene.add_child(npc)
	npc.global_position = pos
	npc.inside_bus = null
	npc.sprite.global_rotation = randf()*TAU
	return npc


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
