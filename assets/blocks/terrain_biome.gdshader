shader_type spatial;

uniform sampler2D noise_r;
uniform sampler2D noise_g;
uniform sampler2D noise_b;
uniform vec3 bottom_color: source_color = vec3(0.0, 0.2, 1.0);
uniform vec3 sedimentary: source_color = vec3(0.0, 0.2, 1.0);

void fragment() {
	vec4 pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 coord = pos.xz / 256.0;
	float r = texture(noise_r, coord).x;
	float g = texture(noise_g, coord).x;
	float b = texture(noise_b, coord).x;
	ALBEDO = mix(bottom_color, sedimentary, 0.1 + sin(pos.y / 1.0) * .1);
	ALBEDO = mix(ALBEDO.rgb, vec3(r, g, b), .1);
}
