class_name Stink
extends Node2D


@export var stink_cloud_scene: PackedScene
@export var canvas_group: CanvasGroup


var timer: float = 0.0
var interval: float = 0.2


func _process(delta: float) -> void:
	timer += delta
	if timer > interval:
		timer -= interval
		release_stink_cloud()


func release_stink_cloud():
	var stink_cloud: StinkCloud = stink_cloud_scene.instantiate()
	canvas_group.add_child(stink_cloud)
	stink_cloud.global_position = global_position + Vector2(randf_range(-2,2),randf_range(-2,2))
