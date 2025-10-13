shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D dif_texture : filter_linear;
uniform sampler2D dif_texture_no_filter : filter_nearest;
uniform sampler2D material_texture : filter_linear;
uniform sampler2D material_texture_no_filter : filter_nearest;
uniform bool no_filter = false;
uniform bool no_material_filter = false;
uniform float strength = 0.4;

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
	ALBEDO = vec3(color.r, color.g, color.b);
	EMISSION = ALBEDO * material_color.r * 2.0;
	ROUGHNESS = material_color.g;
	METALLIC = material_color.b;
	
	// normal
	vec2 texel = vec2(1.0 / 512.0);
    float hL = texture(dif_texture, UV - vec2(texel.x, 0.0)).r;
    float hR = texture(dif_texture, UV + vec2(texel.x, 0.0)).r;
    float hD = texture(dif_texture, UV - vec2(0.0, texel.y)).r;
    float hU = texture(dif_texture, UV + vec2(0.0, texel.y)).r;

    float dx = (hR - hL) * strength;
    float dy = (hU - hD) * strength;

    NORMAL = normalize(NORMAL + vec3(-dx, -dy, 0.0));
}
