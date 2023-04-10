shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform float cycle_interval : hint_range(0.5, 5.0) = 1.0;
uniform float shine_speed : hint_range(1.0, 5.0) = 3.0;
uniform float shine_width : hint_range(1.0, 100.0) = 3.0;

void fragment( )
{
	vec4 pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float width = shine_width * 0.001 * 1.0;
	float frequency = floor( sin( VERTEX.z * cycle_interval + TIME * shine_speed * cycle_interval ) + width );
	ALBEDO = vec3(1, 1, 1);
}