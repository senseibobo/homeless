class_name StinkCloud
extends Node2D


@export var area: Area2D


var velocity: Vector2


var time: float = 0.0
var destroying: bool = false
var in_bus: bool = false
var rotation_speed: float = randf_range(-0.5,0.5)


func _ready():
	velocity = Vector2.ONE.rotated(randf()*TAU)*(1+randf()*3.0)
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).from(0.0)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5).from(Vector2(0.5,0.5))


func _physics_process(delta: float) -> void:
	_process_time(delta)
	_process_movement(delta)
	_process_out_of_bus_movement(delta)


func _process_time(delta):
	time += delta
	rotation += rotation_speed * delta
	scale = Vector2.ONE*(1.0+sin(time*2.0)*0.2)
	if time > 5.0 and not destroying:
		destroy()


func _process_movement(delta):
	global_position += velocity * delta


func _process_out_of_bus_movement(delta):
	in_bus = Bus.current_bus.bus_area in area.get_overlapping_areas()
	if not in_bus and is_instance_valid(Bus.current_bus):
		global_position.x += Bus.current_bus.current_speed*delta


func destroy():
	destroying = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(queue_free)
