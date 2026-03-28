shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float pull_strength : hint_range(0.0, 2.0) = 0.5;
uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform vec4 edge_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	
	vec2 center = vec2(0.5, 0.5);
	
	vec2 diff = uv - center;
	float dist = length(diff);
	
	float offset = sin(dist * 20.0 - TIME * speed) * pull_strength * dist;
	
	vec2 distorted_uv = uv - normalize(diff) * offset;
	
	vec3 screen_color = texture(SCREEN_TEXTURE, distorted_uv).rgb;
	
	float edge_mask = pow(dist * 2.0, 3.0);
	vec3 final_color = mix(screen_color, edge_color.rgb, edge_mask * 0.5);
	
	ALBEDO = final_color;
	ALPHA = 1.0;
}
