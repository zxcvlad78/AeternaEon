shader_type canvas_item;

uniform float speed : hint_range(0, 5) = 1.0;
uniform vec2 size = vec2(100.0, 100.0);

void fragment() {
    float time = TIME * speed;

    // Создание градиента на основе позиции
    vec2 uv = FRAGCOORD.xy / size;

    // Переливающиеся цвета
    vec3 color1 = vec3(
        sin(time) * 0.5 + 0.5,
        cos(time * 1.3) * 0.5 + 0.5,
        sin(time * 0.7) * 0.5 + 0.5
    );

    vec3 color2 = vec3(
        cos(time * 0.8) * 0.5 + 0.5,
        sin(time * 1.1) * 0.5 + 0.5,
        cos(time * 1.5) * 0.5 + 0.5
    );

    // Смешивание цветов
    vec3 final_color = mix(color1, color2, uv.x);

    COLOR = vec4(final_color, 1);
}