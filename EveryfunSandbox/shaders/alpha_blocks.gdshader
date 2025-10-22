shader_type spatial;

uniform sampler2D dif_texture : filter_linear;
uniform sampler2D dif_texture_no_filter : filter_nearest;
uniform bool no_filter = false;

uniform sampler2D material_texture : filter_linear;
uniform sampler2D material_texture_no_filter : filter_nearest;
uniform bool no_material_filter = false;

uniform sampler2D normals_texture : filter_linear;
uniform bool use_normals_texture = false;

uniform bool auto_normals = false;
uniform vec4 tint_color = vec4(1, 1, 1, 1);

const float checkOffset = 1.0 / 512.0;
const float strength = 0.7;

float get_luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

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
	ALPHA = color.a;
	
	// normal
	if (use_normals_texture) {
		vec3 normal = texture(normals_texture, UV).rgb;
	    normal *= 2.0;
	    normal -= 1.0;
		NORMAL = normalize(NORMAL + normal);
	} else if (auto_normals) {
	    float hL = get_luminance(texture(dif_texture, UV - vec2(checkOffset, 0.0)).rgb);
	    float hR = get_luminance(texture(dif_texture, UV + vec2(checkOffset, 0.0)).rgb);
	    float hD = get_luminance(texture(dif_texture, UV - vec2(0.0, checkOffset)).rgb);
	    float hU = get_luminance(texture(dif_texture, UV + vec2(0.0, checkOffset)).rgb);

	    float dx = (hR - hL) * strength;
	    float dy = (hU - hD) * strength;

	    NORMAL = normalize(NORMAL + vec3(-dx, -dy, 0.0));
	}
}
