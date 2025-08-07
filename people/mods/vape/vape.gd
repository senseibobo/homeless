class_name Vape
extends Node2D


@export var animation_player: AnimationPlayer
@export var vape_cloud_scene: PackedScene
@export var vape_clouds_start_position: Marker2D


var vape_cloud_count: int = 30
var timer: float = 0.0
var time: float = 3.0+2.0*randf()

func _process(delta):
	timer += delta
	if timer > time:
		timer = 0.0
		time = 8.0 + randf()*4.0
		puff()


func puff():
	animation_player.play("puff")


func exhale():
	var canvas_group := CanvasGroup.new()
	get_tree().current_scene.add_child(canvas_group)
	canvas_group.modulate.a = 0.65
	canvas_group.z_index = 7
	for i in vape_cloud_count:
		var vape_cloud: VapeCloud = vape_cloud_scene.instantiate()
		vape_cloud.global_position = vape_clouds_start_position.global_position
		var start_velocity: float = 10.0 + randf()*10.0
		var rot = global_rotation + randf()*0.5 + PI
		vape_cloud.velocity = Vector2.RIGHT.rotated(rot)*start_velocity
		canvas_group.add_child.call_deferred(vape_cloud)
		await get_tree().create_timer(0.02, false, false, false).timeout
	await get_tree().create_timer(10.0, false, false, false).timeout
	canvas_group.queue_free()
		
		
