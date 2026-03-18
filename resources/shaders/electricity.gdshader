shader_type spatial;
render_mode blend_add, cull_disabled, unshaded;

uniform sampler2D SCREEN_TEXTURE;
uniform vec4 core_color : source_color = vec4(0.05, 0.0, 0.1, 0.6);
uniform vec4 lightning_color : source_color = vec4(0.7, 0.4, 1.0, 1.0);
uniform float speed : hint_range(0.1, 20.0) = 10.0;
uniform float transparency : hint_range(0.0, 1.0) = 0.5;

// Функция для генерации случайного шума
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Простой шум для молний
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x),
               mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
    // 1. Френель (свечение по краям)
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 2.5);
    
    // 2. Генерация молний через наложение слоев шума
    vec2 uv = UV * 2.0;
    float n = noise(uv + TIME * speed * 0.1);
    
    // Создаем тонкие яркие линии (разрез шума)
    float lightning = 1.0 - abs(noise(uv * 3.0 - TIME * 0.5) - 0.5);
    lightning = pow(lightning, 15.0); // Делаем линии очень тонкими
    
    // 3. Композиция цвета
    vec3 final_color = mix(core_color.rgb, lightning_color.rgb, lightning * 2.0);
    final_color += lightning_color.rgb * fresnel; // Добавляем свечение на края
    
    ALBEDO = final_color;
    
    // Прозрачность зависит от Френеля (края видны лучше) и вспышек молний
    float alpha_mask = fresnel * transparency + (lightning * 0.8);
    ALPHA = clamp(alpha_mask, 0.0, 1.0);
}
