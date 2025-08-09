extends Node


@export var idle_player: AudioStreamPlayer
@export var acceleration_player: AudioStreamPlayer
@export var people_player: AudioStreamPlayer


@onready var bus: Bus = get_parent()

var old_bus_speed: float = 0.0


func _process(delta: float) -> void:
	var a: float = max((bus.current_speed-old_bus_speed)/delta,0)
	idle_player.volume_linear = lerp(idle_player.volume_linear, 1.0/(pow(a,0.25)+1.0), delta)
	acceleration_player.volume_linear = 1- idle_player.volume_linear
	old_bus_speed = bus.current_speed
	people_player.volume_linear = pow((bus.people.size() - 1)/10.0,0.2)
