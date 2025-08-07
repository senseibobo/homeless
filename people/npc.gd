class_name Npc
extends Person


var stinky: bool = randi()%100 < 10 #% chance
@export var stink_particles: CPUParticles2D
@export var npc_textures: Array[Texture2D]


func _ready():
	super()
	_init_ai()
	last_change = Time.get_ticks_msec()
	sprite.texture = npc_textures.pick_random()


func _physics_process(delta):
	super(delta)
	if global_position.distance_squared_to(Vector2()) > 70000: queue_free()


func exit_bus(bus: Bus):
	started_exiting.emit()
	var exit_point: Vector2 = bus.get_closest_exit_point(global_position)
	exit_point.x += randf_range(2,2)
	exit_point.y += randf_range(2,2)
	set_destination(exit_point)
	await bus.open_doors
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
