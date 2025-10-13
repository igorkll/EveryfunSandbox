shader_type spatial;
render_mode unshaded;

uniform sampler2D display_texture : filter_linear;
uniform float display_x;
uniform float display_y;

void fragment() {
	vec2 uv = vec2(floor(UV.x * display_x) / display_x, floor(UV.y * display_y) / display_y);
	ALBEDO = texture(display_texture, uv).rgb;
}
