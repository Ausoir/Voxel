shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec4 Albedo : source_color;
uniform vec4 Emission : source_color;
uniform float HowShiny = 2;
uniform float Roughness = 0.2;


void fragment() {
	ALBEDO = Albedo.rgb;
	EMISSION = Emission.rgb * (0.01 + sin(TIME * 0.1)*.01);
	METALLIC = HowShiny;
	ROUGHNESS = Roughness + cos(TIME * 1.5)*.05;
}
