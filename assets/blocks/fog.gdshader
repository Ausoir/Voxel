shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
global uniform vec3 background;

void fragment() {
	vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc= vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX* vec4(ndc, 1.0);
	view.xyz /= view.w;
	depth = view.z*view.z + view.x*view.x;
	depth = sqrt(depth) - 64.0;
	depth = clamp(depth / 16.0, 0, 1.0);
	
	//ALBEDO = mix(original.rgb, background, depth);
	ALBEDO = original.rgb;
	//ALPHA = original.a;
	//ALBEDO = background;
	ALPHA = depth;
}