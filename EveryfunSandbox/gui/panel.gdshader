shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.4;
uniform float alpha : hint_range(0.0, 1.0) = 0.4;
uniform int blur_steps : hint_range(1, 128) = 8;
uniform float blur_size : hint_range(0.0, 512.0) = 64.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

const vec4 color = vec4(0.7, 0.7, 0.7, 1);

void fragment() {
	if (false) {
		COLOR = vec4(0, 0, 0, 0);
	} else {
		vec2 screen_resolution = vec2(textureSize(SCREEN_TEXTURE, 0));
	
	    vec4 col = vec4(0.0);
	    for (int x = -blur_steps; x <= blur_steps; x++) {
	        for (int y = -blur_steps; y <= blur_steps; y++) {
	            vec2 offset = (vec2(float(x) / float(blur_steps), float(y) / float(blur_steps)) * blur_size) / screen_resolution;
	            col += texture(SCREEN_TEXTURE, SCREEN_UV + offset);
	        }
	    }
	    col /= float((blur_steps * 2 + 1) * (blur_steps * 2 + 1));
		
	    COLOR = mix(vec4(col.rgb, 1), color, alpha);
	}
}
