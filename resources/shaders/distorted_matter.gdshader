shader_type spatial;
// Убираем unshaded, чтобы шейдер корректно работал с прозрачностью и очередью отрисовки
render_mode blend_mix, depth_draw_never, unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float pull_strength : hint_range(0.0, 2.0) = 0.5;
uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform vec4 edge_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5, 0.5);
	vec2 diff = uv - center;
	float dist = length(diff);
	
	// Используем COLOR.r как маску, чтобы ограничить область эффекта на меше
	float v_mask = COLOR.r;
	
	float offset = sin(dist * 20.0 - TIME * speed) * (pull_strength * v_mask) * dist;
	
	// Искажаем только координаты для текстуры фона
	vec2 distorted_uv = uv - normalize(diff) * offset;
	
	// Захватываем только то, что УЖЕ отрисовано (непрозрачный мир)
	vec3 bg_color = texture(screen_tex, distorted_uv).rgb;
	
	float edge_mask = pow(dist * 2.0, 3.0) * v_mask;
	vec3 final_color = mix(bg_color, edge_color.rgb, edge_mask * 0.5);
	
	ALBEDO = final_color;
	ALPHA = 1.0;
}
