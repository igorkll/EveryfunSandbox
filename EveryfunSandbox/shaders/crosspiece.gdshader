shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec3 bg_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float value = 0.2126 * bg_color.r + 0.7152 * bg_color.g + 0.0722 * bg_color.b;
	float newValue = 0.0;
	if (value > 0.1) {
		newValue = 0.0;
	} else {
		newValue = 1.0;
	}
	COLOR = vec4(newValue, newValue, newValue, COLOR.a);
}

