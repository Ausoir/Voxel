shader_type spatial;

uniform vec3 out_color: source_color = vec3(0.0, 0.2, 1.0);
uniform vec3 out_color2: source_color = vec3(0.0, 0.2, 1.0);

float generateOffset(float x, float z, float val1, float val2, float time) {
	float radiansX = ((mod(x + z * x * val1, 0.4) / 0.4) + time) * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), 0.4) / 0.4) + time) * 3.14;
	
	return (sin(radiansZ) * cos(radiansX)) * 0.2;
}

vec3 distort(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time + .1);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time + .2);
	
	return vertex + vec3(xd/8.0, yd, zd/8.0);
}

void vertex() {
	VERTEX = distort(VERTEX, TIME * 0.5);
}

void fragment() {
	vec4 pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float hash = fract(sin(dot(round(pos.xyz) * 2.0, vec3(12.9898,78.233,254.1234))) * 43758.5453);
	ALBEDO = mix(out_color2, out_color, hash);
}