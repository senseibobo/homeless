class_name Bus
extends StaticBody2D


static var current_bus: Bus


signal open_doors
signal close_doors


var current_speed: float = 0.0
var max_speed: float = 200.0
var acceleration_time: float = 2.0
var deceleration_time: float = 2.4
var chairs: Array[BusChair]
var overcrowdedness: int = randi_range(3,10)
@export var npc_scene: PackedScene
@export var spawn_markers_node: Node2D


func do_driving_loop():
	while true:
		await start_driving()
		await get_tree().create_timer(1.0).timeout
		await stop_driving()


func _ready():
	for i in overcrowdedness:
		var arr = spawn_markers_node.get_children()
		var marker: Node2D = arr.pop_at(randi()%arr.size())
		spawn_npc(marker.global_position)


func spawn_npc(pos: Vector2):
	var npc = npc_scene.instantiate()
	npc.global_position = pos
	npc.inside_bus = self
	npc.global_rotation = randf()*TAU
	add_child(npc)
	if randi()%2 == 0:
		var chair_index = randi()%31
		var chair: BusChair = chairs[chair_index]
		if chair.person_sitting == null:
			npc.sit_on_chair(chair)


func _process(delta):
	if current_bus == self:
		if Road.road:
			Road.road.movement_speed = current_speed
	else:
		global_position.x -= current_speed*delta
		if global_position.x < -160:
			queue_free()


func start_driving():
	var tween: Tween = create_tween()
	tween.tween_property(self, "current_speed", max_speed, acceleration_time)
	await tween.finished


func stop_driving():
	var tween: Tween = create_tween()
	tween.tween_property(self, "current_speed", 0.0, deceleration_time)
	var a = current_speed / deceleration_time
	if current_bus == self:
		Road.road.spawn_station(get_s_from_v0at(current_speed, a, deceleration_time), deceleration_time)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	open_doors.emit()
	await get_tree().create_timer(2.0).timeout
	close_doors.emit()
	await get_tree().create_timer(1.0).timeout


func get_s_from_v0at(v0: float, a: float, t: float):
	return v0*t - (2*a*pow(t,2.0))


func _on_bus_area_body_entered(body: Node2D) -> void:
	if body is Player:
		current_bus = self
		body.inside_bus = self


func _on_bus_area_body_exited(body: Node2D) -> void:
	if body is Player and current_bus == self:
		current_bus = null
		body.inside_bus = null


func get_nearest_chair(to_position: Vector2, unoccupied: bool = true):
	var nearest: BusChair = null
	var nearest_distance: float = INF
	for chair in chairs:
		if unoccupied and chair.person_sitting != null: continue
		var distance: float = chair.global_position.distance_to(to_position) 
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = chair
	return nearest
