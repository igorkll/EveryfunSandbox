shader_type spatial;
render_mode unshaded;

uniform sampler2D display_texture : filter_linear;
uniform float display_x;
uniform float display_y;

void fragment() {
	ALBEDO = texture(display_texture, UV).rgb;
}
