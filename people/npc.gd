class_name Npc
extends Person


var stinky: bool = randi()%100 < 10 #% chance
@export var stink_particles: CPUParticles2D
@export var npc_textures: Array[Texture2D]


func _ready():
	super()
	stink_particles.emitting = stinky
	_init_ai()
	entered_bus.connect(_on_bus_entered)
	exited_bus.connect(_on_bus_exited)
	last_change = Time.get_ticks_msec()
	sprite.texture = npc_textures.pick_random()


func exit_bus():
	started_exiting.emit()
	var exit_point: Vector2 = inside_bus.get_closest_exit_point(global_position)
	exit_point.x += randf_range(2,2)
	exit_point.y += randf_range(2,2)
	set_destination(exit_point)
	await inside_bus.open_doors
	set_destination(exit_point + Vector2.UP*(20+randf_range(0,10)))


func enter_bus():
	started_entering.emit()
	var enter_point: Vector2 = Bus.current_bus.get_closest_enter_point(global_position)
	enter_point.x += randf_range(2,2)
	enter_point.y += randf_range(2,2)
	set_destination(enter_point)
	await Bus.current_bus.open_doors
	set_destination(enter_point + Vector2.DOWN*(20+randf_range(0,10)))
	await entered_bus



func _on_bus_entered(bus: Bus):
	print("bus enteredd")
	reparent.call_deferred(bus)


func _on_bus_exited(bus: Bus):
	print("bus exiteddd")
	reparent.call_deferred(Station.current_station)
