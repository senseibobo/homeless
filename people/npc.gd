class_name Npc
extends Person


static var npcs: Array[Npc]


enum AIState
{
	STANDING,
	SITTING,
	EXITING,
	ENTERING
}


@export var npc_textures: Array[Texture2D]
@export var debug_label: Label

var ai_state: AIState = AIState.STANDING
var stations_left: int = 0
var random_bus_thing_timer: float = 0.0
var random_bus_thing_time: float = 1.0 + randf()*2.0
var stinky: bool = randi()%100 < 10 #% chance


func _ready():
	super()
	npcs.append(self)
	last_change = Time.get_ticks_msec()
	sprite.texture = npc_textures.pick_random()
	stood_up.connect(_on_stood_up)
	sat_down.connect(_on_sat_down)


func _exit_tree() -> void:
	super()
	npcs.erase(self)


func _physics_process(delta):
	super(delta)
	if global_position.distance_squared_to(Vector2()) > 70000: queue_free()


func _process(delta):
	super(delta)
	_process_ai(delta)
	_update_debug_label()


func _update_debug_label():
	var text: String
	text += str("stations left: ", stations_left, "\n")
	text += str("state: ", AIState.keys()[ai_state], "\n")
	text += str("bus_thing: ", int(random_bus_thing_timer/random_bus_thing_time*100.0), "%\n")
	debug_label.text = text


func _process_ai(delta):
	match ai_state:
		AIState.STANDING:
			random_bus_thing_timer += delta
			if random_bus_thing_timer > random_bus_thing_time:
				_on_random_bus_thing_timer_timeout()
		AIState.SITTING:
			pass


func _on_random_bus_thing_timer_timeout():
	random_bus_thing_timer = -1000000.0
	await do_random_bus_thing()
	random_bus_thing_timer = 0.0


func sit_on_chair(chair: BusChair):
	super(chair)
	ai_state = AIState.SITTING


func exit_bus():
	started_exiting.emit()
	var exit_point: Vector2 = Bus.current_bus.get_closest_exit_point(global_position)
	exit_point.x += randf_range(2,2)
	exit_point.y += randf_range(2,2)
	set_destination(exit_point)
	ai_state = AIState.EXITING
	await Bus.current_bus.open_doors
	set_destination(exit_point + Vector2.UP*15)
	await exited_bus


func enter_bus():
	ai_state = AIState.ENTERING
	started_entering.emit()
	var enter_point: Vector2 = Bus.current_bus.get_closest_enter_point(global_position)
	enter_point.x += randf_range(2,2)
	enter_point.y += randf_range(2,2)
	set_destination(enter_point)
	await arrived
	set_destination(enter_point + Vector2.DOWN*11)
	await entered_bus
	

func _on_entered_bus(bus: Bus):
	stations_left = 2+randi()%6
	ai_state = AIState.STANDING
	await get_tree().create_timer(1.0+randf()*2.0).timeout
	do_random_bus_thing()


func _on_exited_bus(bus: Bus):
	ai_state = AIState.STANDING
	#do_random_station_thing()


func _on_bus_started_decelerating():
	if not inside_bus: return
	stations_left -= 1
	
	if stations_left == 0:
		exit_bus()


func _on_bus_started_accelerating():
	pass


func _on_stood_up():
	ai_state = AIState.STANDING


func _on_sat_down(chair: BusChair):
	ai_state = AIState.SITTING
