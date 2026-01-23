shader_type canvas_item;

const float alpha = 0.4;
const int blur_steps = 8;
const float blur_size = 0.01;
const float anim_speed = 8.0;
const float anim_stretch = 8.0;
const vec2 rgbShiftR = vec2(-8, 0);
const vec2 rgbShiftG = vec2(0, 0);
const vec2 rgbShiftB = vec2(8, 0);
const vec2 rgbShiftA = vec2(0, 0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 color = vec4(0.6, 0.6, 0.6, 1);
uniform vec4 progressColor = vec4(0.2, 0.2, 0.8, 1);
uniform float timeout = 0.0;
uniform bool processAnimation = false;

vec2 calcOffset(int x, int y, float blur_size_px, vec2 _SCREEN_PIXEL_SIZE, vec2 offset2) {
	return vec2((float(x) + offset2.x) / float(blur_steps), (float(y) + offset2.y) / float(blur_steps)) * blur_size_px * _SCREEN_PIXEL_SIZE;
}

void fragment() {
	float blur_size_px = blur_size / SCREEN_PIXEL_SIZE.y;

    vec4 col = vec4(0.0);
    for (int x = -blur_steps; x <= blur_steps; x++) {
        for (int y = -blur_steps; y <= blur_steps; y++) {
            col.r += texture(SCREEN_TEXTURE, SCREEN_UV + calcOffset(x, y, blur_size_px, SCREEN_PIXEL_SIZE, rgbShiftR)).r;
            col.g += texture(SCREEN_TEXTURE, SCREEN_UV + calcOffset(x, y, blur_size_px, SCREEN_PIXEL_SIZE, rgbShiftG)).g;
            col.b += texture(SCREEN_TEXTURE, SCREEN_UV + calcOffset(x, y, blur_size_px, SCREEN_PIXEL_SIZE, rgbShiftB)).b;
	        col.a += texture(SCREEN_TEXTURE, SCREEN_UV + calcOffset(x, y, blur_size_px, SCREEN_PIXEL_SIZE, rgbShiftA)).a;
        }
    }
    col /= float((blur_steps * 2 + 1) * (blur_steps * 2 + 1));
	
	vec4 currentColor;
	if (processAnimation) {
		currentColor = mix(color, progressColor, (sin((UV.x * anim_stretch) - (TIME * anim_speed)) + 1.0) / 2.0);
	} else if (UV.x < timeout) {
		currentColor = progressColor;
	} else {
		currentColor = color;
	}
    COLOR = mix(vec4(col.rgb, 1), currentColor, alpha);
}
