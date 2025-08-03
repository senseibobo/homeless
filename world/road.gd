class_name Road
extends Sprite2D


static var road: Road

var movement_speed: float = 0.0
@export var station_scene: PackedScene



func _ready():
	road = self


func _process(delta: float) -> void:
	global_position.x += delta*movement_speed
	global_position.x = fposmod(global_position.x, 160)


func spawn_station(x_distance: float, time_to_reach: float):
	var station: Station = station_scene.instantiate()
	get_tree().current_scene.add_child(station)
	station.global_position = Vector2(x_distance/2.0, -35.0)
