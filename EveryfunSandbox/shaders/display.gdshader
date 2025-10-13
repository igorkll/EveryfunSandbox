shader_type spatial;
render_mode unshaded;

uniform sampler2D display_texture : filter_linear;
uniform float display_x = 0;
uniform float display_y = 0;

void fragment() {
	vec2 uv = UV;
	if (display_x > 0.0) {
		uv = vec2(floor(UV.x * display_x) / display_x, floor(UV.y * display_y) / display_y);
	}
	ALBEDO = texture(display_texture, uv).rgb;
}
