shader_type spatial;

uniform sampler2D display_texture : filter_linear;
uniform float display_x = 0;
uniform float display_y = 0;
uniform bool display_flip_x = false;
uniform bool display_flip_y = false;

void fragment() {
	vec2 uv = UV;
	if (display_x > 0.0) uv = vec2(floor(UV.x * display_x) / display_x, floor(UV.y * display_y) / display_y);
	if (display_flip_x) uv.x = -uv.x;
	if (display_flip_y) uv.y = -uv.y;
	ALBEDO = texture(display_texture, uv * 0.998).rgb;
	EMISSION = ALBEDO * 0.4;
}

void light() {
	DIFFUSE_LIGHT = vec3(0, 0, 0);
}