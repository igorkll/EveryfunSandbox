shader_type spatial;

uniform sampler2D dif_texture : filter_linear;
uniform sampler2D dif_texture_no_filter : filter_nearest;
uniform bool no_filter = false;

uniform sampler2D material_texture : filter_linear;
uniform sampler2D material_texture_no_filter : filter_nearest;
uniform bool no_material_filter = false;

uniform sampler2D normals_texture : filter_linear;
uniform bool use_normals_texture = false;

uniform vec4 tint_color = vec4(1, 1, 1, 1);

void fragment() {
	vec4 color;
	if (no_filter) {
	    color = texture(dif_texture_no_filter, UV).rgba;
	} else {
		color = texture(dif_texture, UV).rgba;
	}
	
	vec4 material_color;
	if (no_material_filter) {
	    material_color = texture(material_texture_no_filter, UV);
	} else {
		material_color = texture(material_texture, UV);
	}
	
	color *= tint_color;
	ALBEDO = vec3(color.r, color.g, color.b);
	EMISSION = ALBEDO * material_color.r * 2.0;
	ROUGHNESS = material_color.g;
	METALLIC = material_color.b;
	// ALPHA = color.a;
	
	if (use_normals_texture) {
		NORMAL_MAP = texture(normals_texture, UV).rgb;
	}
}
