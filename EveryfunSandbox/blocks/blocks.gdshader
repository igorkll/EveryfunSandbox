shader_type spatial;

uniform sampler2D diff_texture;

void fragment() {
    ALBEDO = texture(diff_texture, UV).rgb;
}