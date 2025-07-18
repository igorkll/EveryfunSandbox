shader_type spatial;

uniform float speed = 0.3;
uniform vec2 center = vec2(0.5, 0.5);

vec3 hsv_to_rgb(float h, float s, float v) {
    vec3 rgb;
    if (s == 0.0) {
        rgb = vec3(v);
    } else {
        float f = fract(h * 6.0);
        float p = v * (1.0 - s);
        float q = v * (1.0 - f * s);
        float t = v * (1.0 - (1.0 - f) * s);

        if (h < 1.0 / 6.0) {
            rgb = vec3(v, t, p);
        } else if (h < 2.0 / 6.0) {
            rgb = vec3(q, v, p);
        } else if (h < 3.0 / 6.0) {
            rgb = vec3(p, v, t);
        } else if (h < 4.0 / 6.0) {
            rgb = vec3(p, q, v);
        } else if (h < 5.0 / 6.0) {
            rgb = vec3(t, p, v);
        } else {
            rgb = vec3(v, p, q);
        }
    }
    return rgb;
}

void fragment() {
	float time = TIME * speed;
	float offset = (1.0 - distance(UV, center));
	ALBEDO = hsv_to_rgb(fract(time - offset), 1.0, 1.0);
}
