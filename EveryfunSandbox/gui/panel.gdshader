shader_type canvas_item;

uniform float border : hint_range(0.0, 1.0) = 0.02;
uniform float alpha : hint_range(0.0, 1.0) = 0.4;
uniform int blur_steps : hint_range(1, 128) = 8;
uniform float blur_size : hint_range(0.0, 1.0) = 0.01;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
const vec4 panelColor = vec4(0.7, 0.7, 0.7, 1);
const vec4 borderColor = vec4(0.2, 0.2, 0.2, 1);

void fragment() {
	vec2 texture_resolution = vec2(textureSize(TEXTURE, 0));
	vec2 screen_resolution = vec2(textureSize(SCREEN_TEXTURE, 0));
	float texture_aspect_ratio = float(texture_resolution.x) / float(texture_resolution.y);
	float blur_size_px = blur_size * screen_resolution.y;

    vec4 col = vec4(0.0);
    for (int x = -blur_steps; x <= blur_steps; x++) {
        for (int y = -blur_steps; y <= blur_steps; y++) {
            vec2 offset = (vec2(float(x) / float(blur_steps), float(y) / float(blur_steps)) * blur_size_px) / screen_resolution;
            col += texture(SCREEN_TEXTURE, SCREEN_UV + offset);
        }
    }
    col /= float((blur_steps * 2 + 1) * (blur_steps * 2 + 1));
	
	vec2 dist_to_edge = min(UV, vec2(1.0) - UV);
	float min_dist_to_edge = min(dist_to_edge.x, dist_to_edge.y);
	
	vec4 color = panelColor;
	if (min_dist_to_edge <= border) {
		color = borderColor;
	}
    COLOR = mix(vec4(col.rgb, 1), color, alpha);
}
