shader_type spatial;

uniform vec3 color_bottom = vec3(0.0, 1.0, 0.0);
uniform vec3 color_top = vec3(1.0, 1.0, 0.0);

void fragment() {
    ALBEDO = mix(color_bottom, color_top, UV.y);
}