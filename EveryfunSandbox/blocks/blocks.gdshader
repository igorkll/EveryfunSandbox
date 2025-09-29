shader_type spatial;

uniform sampler2D diff_texture : filter_linear;
uniform sampler2D diff_texture_no_filter : filter_nearest;
uniform bool no_filter = false;

void fragment() {
	if (no_filter) {
	    ALBEDO = texture(diff_texture_no_filter, UV).rgb;
	} else {
		ALBEDO = texture(diff_texture, UV).rgb;
	}
}