class_name World
extends Node2D

static var instance: World

@export var first_bus: Bus
@export var navigation_region: NavigationRegion2D


func _ready():
	World.instance = self
	Bus.current_bus = first_bus 
	first_bus.do_driving_loop()
