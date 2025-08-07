shader_type canvas_item;

uniform float color_count: hint_range(1.0, 16.0, 1.0);
uniform float smoke_strength: hint_range(0.0, 1.0) = 0.5;
uniform float smoke_radius: hint_range(0.0, 1.0) = 0.5;
uniform float smoke_feather: hint_range(0.0, 1.0) = 0.3;
uniform vec2 smoke_center;
uniform sampler2D noise_texture: filter_nearest, repeat_enable;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	float aspect_ratio = 16.0/9.0;
	vec4 sample1 = texture(noise_texture, UV + TIME*0.25);
	vec4 sample2 = texture(noise_texture, UV - TIME*0.25);
	vec4 mixed_smoke = mix(sample1,sample2,0.5);
	mixed_smoke.a = clamp(mixed_smoke.a*smoke_strength*8.0, 0.0, 1.0);
	mixed_smoke = round(mixed_smoke*color_count)/color_count;
	
	vec4 screen_sample = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 scaled_uv = vec2(UV.x*aspect_ratio, UV.y);
	vec2 scaled_center = vec2(smoke_center.x*aspect_ratio, smoke_center.y);
	float mix_amount = clamp(distance(scaled_uv, scaled_center),0.0,1.0);
	mix_amount = 1.0-mix_amount;
	mix_amount = smoothstep(mix_amount, 1.0-smoke_radius, max(mix_amount, smoke_feather))*smoke_strength;
	COLOR = mix(screen_sample, mixed_smoke, mix_amount);
}