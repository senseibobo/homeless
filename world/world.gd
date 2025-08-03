extends Node2D


@export var first_bus: Bus


func _ready():
	first_bus.do_driving_loop()
