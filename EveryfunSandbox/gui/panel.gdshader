shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.4;
uniform float alpha : hint_range(0.0, 1.0) = 0.6;
uniform int blur_steps : hint_range(1, 32) = 8;
uniform float blur_size : hint_range(0.0, 10.0) = 4.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 col = vec4(0.0);
    for (int x = -blur_steps; x <= blur_steps; x++) {
        for (int y = -blur_steps; y <= blur_steps; y++) {
            //vec2 offset = vec2(float(x), float(y)) * blur_size / VIEWPORT_SIZE;
            col += texture(SCREEN_TEXTURE, SCREEN_UV);
        }
    }
    col /= float((blur_steps * 2 + 1) * (blur_steps * 2 + 1));
	
	if (true) {
		COLOR = vec4(0, 0, 0, 0);
	} else {
	    COLOR = col;
	}
}
