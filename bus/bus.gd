class_name Bus
extends StaticBody2D


static var current_bus: Bus
static var player_in_bus: bool = true


signal open_doors
signal close_doors
signal started_decelerating
signal started_accelerating


var current_speed: float = 0.0
var max_speed: float = 200.0
var acceleration_time: float = 2.0
var deceleration_time: float = 2.4
var chairs: Array[BusChair]
var people: Array[Person]
var overcrowdedness: int = randi_range(3,10)
var recalculate_npc_count_timer: float = 0.0
@export var npc_scene: PackedScene
@export var spawn_markers_node: Node2D
@export var enter_points_node: Node2D
@export var exit_points_node: Node2D
@export var bus_area: Area2D


func do_driving_loop():
	while true:
		await start_driving()
		await get_tree().create_timer(1.0).timeout
		Road.road.spawn_station(get_station_pos(), deceleration_time)
		await stop_driving()


func _ready():
	current_bus = self
	await get_tree().process_frame
	await get_tree().process_frame
	for i in overcrowdedness:
		var arr = spawn_markers_node.get_children()
		var marker: Node2D = arr.pop_at(randi()%arr.size())
		spawn_npc(marker.global_position)


func _exit_tree():
	current_bus = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		spawn_npc(Vector2())


func spawn_npc(pos: Vector2):
	var npc = npc_scene.instantiate()
	npc.global_position = pos
	npc.inside_bus = self
	npc.sprite.global_rotation = randf()*TAU
	get_tree().current_scene.add_child.call_deferred(npc)
	if randi()%2 == 0:
		var chair_index = randi()%31
		var chair: BusChair = chairs[chair_index]
		if chair.person_sitting == null:
			npc.sit_on_chair(chair)


func get_station_pos():
	return get_s_from_v0at(current_speed, current_speed / deceleration_time, deceleration_time)


func _process(delta):
	if player_in_bus:
		if Road.road:
			Road.road.movement_speed = current_speed
	else:
		global_position.x -= current_speed*delta
		if global_position.x < -160:
			for npc in Npc.npcs:
				if npc.inside_bus == self:
					npc.queue_free()
			queue_free()
	


func start_driving():
	var tween: Tween = create_tween()
	_on_started_accelerating()
	tween.tween_property(self, "current_speed", max_speed, acceleration_time)
	await tween.finished


func stop_driving():
	var tween: Tween = create_tween()
	tween.tween_property(self, "current_speed", 0.0, deceleration_time)
	_on_started_decelerating()
	await tween.finished
	await do_door_open_close_sequence()


func _on_started_accelerating():
	started_accelerating.emit()
	for npc in Npc.npcs:
		npc._on_bus_started_accelerating()


func _on_started_decelerating():
	started_decelerating.emit()
	for npc in Npc.npcs:
		npc._on_bus_started_decelerating()


func do_door_open_close_sequence():
	await get_tree().create_timer(0.5).timeout
	open_doors.emit()
	await get_tree().create_timer(2.0).timeout
	close_doors.emit()
	await get_tree().create_timer(1.0).timeout


func get_s_from_v0at(v0: float, a: float, t: float):
	return v0*t - (2*a*pow(t,2.0))


func _on_bus_area_body_entered(body: Node2D) -> void:
	if body is Person:
		#if body.last_change + 10 > Time.get_ticks_msec(): return
		body.last_change = Time.get_ticks_msec()
		body.inside_bus = self
		body.entered_bus.emit(self)
		if body is Player:
			player_in_bus = true


func _on_bus_area_body_exited(body: Node2D) -> void:
	if body is Person:
		#if body.last_change + 10 > Time.get_ticks_msec(): return
		body.last_change = Time.get_ticks_msec()
		body.inside_bus = null
		body.exited_bus.emit(self)
		if body is Player:
			player_in_bus = false


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


func get_random_point() -> Vector2:
	var map: RID = World.instance.navigation_region.get_navigation_map()
	var size := Vector2(140,32)
	var p: Vector2 = global_position-size/2.0+Vector2.DOWN*10.0
	var point: Vector2 = p + Vector2(randf_range(0,size.x), randf_range(0,size.y)) 
	return NavigationServer2D.map_get_closest_point(map, point)


func get_closest_exit_point(to_point: Vector2) -> Vector2:
	return get_closest_point(exit_points_node, to_point)


func get_closest_enter_point(to_point: Vector2) -> Vector2:
	return get_closest_point(enter_points_node, to_point)


func get_closest_point(points_node: Node, to_point: Vector2) -> Vector2:
	var nearest_distance: float = INF
	var nearest_point: Vector2 = global_position
	for point in points_node.get_children():
		var distance = point.global_position.distance_to(to_point)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_point = point.global_position
	return nearest_point
