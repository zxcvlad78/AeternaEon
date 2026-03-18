shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 ring_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform vec4 inner_color : source_color = vec4(0.2, 0.6, 1.0, 0.2);
uniform float thickness : hint_range(0.0, 0.5) = 0.05;
uniform float radius : hint_range(0.0, 0.5) = 0.45;

void fragment() {
    // Вычисляем расстояние от центра (0.5, 0.5)
    float dist = distance(UV, vec2(0.5));
    
    // Создаем маску для основного круга
    float circle = smoothstep(radius + 0.01, radius, dist);
    
    // Создаем маску для обводки (кольца)
    float border = smoothstep(radius, radius - 0.01, dist) - 
                   smoothstep(radius - thickness, radius - thickness - 0.01, dist);
    
    // Смешиваем цвета: основной фон радиуса + яркая обводка
    vec4 final_color = mix(vec4(0.0), inner_color, circle);
    final_color = mix(final_color, ring_color, border);
    
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}
