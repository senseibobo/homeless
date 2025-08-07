class_name VapeSmokeOverlay
extends ColorRect


var smoke_count: int
var smoke_strength: float = 0.0
var smoke_center: Vector2


func _ready():
	var shader_material: ShaderMaterial = material
	shader_material.set_shader_parameter(&"smoke_strength", 0.0)


func _process(delta):
	if smoke_count > 0 or smoke_strength > 0:
		var shader_material: ShaderMaterial = material
		smoke_strength = lerp(smoke_strength, float(smoke_count > 0), 2*delta)
		if is_instance_valid(Player.instance):
			smoke_center = map_pos_to_uv(Player.instance.global_position)
		shader_material.set_shader_parameter(&"smoke_strength", smoke_strength)
		shader_material.set_shader_parameter(&"smoke_center", smoke_center)


func map_pos_to_uv(pos: Vector2):
	var screen_size = get_viewport_rect().size
	pos += screen_size/2.0
	pos /= screen_size
	return pos
