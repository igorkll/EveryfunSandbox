shader_type spatial;

uniform float speed = 5;
uniform vec3 color1 = vec3(1.0, 0.0, 0.0);
uniform vec3 color2 = vec3(1.0, 1.0, 0.0);

void fragment() {
    float time = TIME * speed;
    float blend = (sin(time) + 1.0) / 2.0;
    vec3 color = mix(color1, color2, blend);
    ALBEDO = color;
}
