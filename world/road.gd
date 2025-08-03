class_name Road
extends Sprite2D


var movement_speed: float = 0.0


func _process(delta: float) -> void:
	global_position.x += delta*movement_speed
	global_position.x = fposmod(global_position.x, 160)
