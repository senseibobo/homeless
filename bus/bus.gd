class_name Bus
extends StaticBody2D


signal open_doors
signal close_doors


var current_speed: float = 0.0
var max_speed: float = 100.0
var acceleration_time: float = 1.5
var deceleration_time: float = 1.0
@export var road: Road


func _ready() -> void:
	while true:
		await start_driving()
		await get_tree().create_timer(10.0).timeout
		await stop_driving()
		await get_tree().create_timer(0.5).timeout
		open_doors.emit()
		await get_tree().create_timer(2.0).timeout
		close_doors.emit()
		await get_tree().create_timer(1.0).timeout


func _process(delta):
	if road:
		road.movement_speed = current_speed


func start_driving():
	var tween: Tween = create_tween()
	tween.tween_property(self, "current_speed", max_speed, acceleration_time)
	await tween.finished


func stop_driving():
	var tween: Tween = create_tween()
	tween.tween_property(self, "current_speed", 0.0, deceleration_time)
	await tween.finished
