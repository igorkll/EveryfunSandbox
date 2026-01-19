shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec3 bg_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 4.0).rgb;
	float value = 0.2126 * bg_color.r + 0.7152 * bg_color.g + 0.0722 * bg_color.b;
	float newValue = clamp(1.0 - (value * 5.0), 0.0, 1.0);
	COLOR = vec4(newValue, newValue, newValue, COLOR.a);
}
