shader_type spatial;

uniform sampler2D dif_texture : filter_nearest;
uniform sampler2D material_texture : filter_nearest;

void fragment() {
	vec4 color = texture(dif_texture, UV).rgba;
	vec4 material_color = texture(material_texture, UV);

	ALBEDO = vec3(color.r, color.g, color.b);
	EMISSION = ALBEDO * material_color.r * 2.0;
	ROUGHNESS = material_color.g;
	METALLIC = material_color.b;
	ALPHA = color.a;
}
