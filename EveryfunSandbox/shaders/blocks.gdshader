shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D diff_texture : filter_linear;
uniform sampler2D diff_texture_no_filter : filter_nearest;
uniform sampler2D material_texture : filter_linear;
uniform sampler2D material_texture_no_filter : filter_nearest;
uniform bool no_filter = false;
uniform bool no_material_filter = false;

void fragment() {
	if (no_filter) {
	    ALBEDO = texture(diff_texture_no_filter, UV).rgb;
	} else {
		ALBEDO = texture(diff_texture, UV).rgb;
	}
	
	vec4 material_color;
	if (no_material_filter) {
	    material_color = texture(material_texture_no_filter, UV);
	} else {
		material_color = texture(material_texture, UV);
	}
	EMISSION = ALBEDO * material_color.r * 2.0;
	ROUGHNESS = material_color.g;
	METALLIC = material_color.b;
}
