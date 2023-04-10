shader_type spatial;

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = 0.9;
	EMISSION = vec3(400.0, 400.0, 400.0);
}
