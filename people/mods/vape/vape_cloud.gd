class_name VapeCloud
extends Node2D


@export var textures: Array[Texture2D]
@export var sprite: Sprite2D
@export var area: Area2D


var in_bus: bool = false
var added_smoke_count: bool = false
var velocity: Vector2
var time: float = 0.0
var destroying: bool = false
var min_speed: float = 0.0

func _ready():
	sprite.texture = textures.pick_random()
	min_speed = randf()*3.0


func _physics_process(delta: float) -> void:
	_process_time(delta)
	_process_movement(delta)
	_process_out_of_bus_movement(delta)


func _process_time(delta):
	time += delta
	scale = Vector2.ONE*(1.0+sin(time*3.0)*0.1)
	if time > 5.0 and not destroying:
		destroy()


func _process_movement(delta):
	global_position += velocity * delta
	velocity = velocity.lerp(velocity.normalized()*min_speed, 1.0*delta)


func _process_out_of_bus_movement(delta):
	if not is_instance_valid(Bus.current_bus) or not Bus.player_in_bus: return
	if not Bus.current_bus.bus_area in area.get_overlapping_areas():
		global_position.x += Bus.current_bus.current_speed*delta


func destroy():
	destroying = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(queue_free)


func _exit_tree():
	if added_smoke_count:
		GameOverlay.vape_smoke_overlay.smoke_count -= 1
		added_smoke_count = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not added_smoke_count:
		GameOverlay.vape_smoke_overlay.smoke_count += 1
		added_smoke_count = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player and added_smoke_count:
		GameOverlay.vape_smoke_overlay.smoke_count -= 1
		added_smoke_count = false
