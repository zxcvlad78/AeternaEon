shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 line_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float radius : hint_range(0.0, 0.5) = 0.5; // 0.5 — всегда край меша
uniform float thickness : hint_range(0.0, 1.0) = 0.05; // Толщина в мировых единицах
uniform float dash_count : hint_range(0, 100) = 40.0;
uniform float animation_speed = 1.0;

void fragment() {
    // Получаем масштаб объекта по оси X (предполагаем равномерный масштаб)
    float world_scale = length(MODEL_MATRIX[0].xyz); 
    
    // Центрируем UV
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    // Толщина линии пересчитывается относительно мирового масштаба
    // Чтобы при скейле объекта 2.0 линия в UV стала в 2 раза тоньше
    float uv_thickness = thickness / world_scale;
    
    // Рисуем кольцо. Внешний радиус завязан на параметр radius (обычно 0.5)
    // Внутренний радиус — это внешний минус высчитанная толщина
    float ring = smoothstep(radius - uv_thickness - 0.005, radius - uv_thickness, dist) 
                - smoothstep(radius, radius + 0.005, dist);
    
    if (dash_count > 0.0) {
        float angle = atan(uv.y, uv.x) + TIME * animation_speed;
        float dash = sin(angle * dash_count);
        ring *= step(0.0, dash);
    }

    ALBEDO = line_color.rgb;
    ALPHA = clamp(ring, 0.0, 1.0) * line_color.a;
}
