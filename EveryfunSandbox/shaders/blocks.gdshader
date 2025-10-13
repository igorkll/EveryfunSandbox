shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D diff_texture : filter_linear;
uniform sampler2D diff_texture_no_filter : filter_nearest;
uniform sampler2D material_texture : filter_linear;
uniform sampler2D material_texture_no_filter : filter_nearest;
uniform bool no_filter = false;
uniform bool no_material_filter = false;

void fragment() {
	vec4 color;
	if (no_filter) {
	    color = texture(diff_texture_no_filter, UV).rgba;
	} else {
		color = texture(diff_texture, UV).rgba;
	}
	
	vec4 material_color;
	if (no_material_filter) {
	    material_color = texture(material_texture_no_filter, UV);
	} else {
		material_color = texture(material_texture, UV);
	}
	ALBEDO = vec3(color.r, color.g, color.b);
	EMISSION = ALBEDO * material_color.r * 2.0;
	ROUGHNESS = material_color.g;
	METALLIC = material_color.b;
	
	//ALPHA = color.a;
}
