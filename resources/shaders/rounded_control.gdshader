shader_type canvas_item;

uniform float softness : hint_range(0.0, 0.5) = 0.01;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    
    float dist = distance(UV, center);
    
    vec4 tex_color = texture(TEXTURE, UV);
    
    float mask = smoothstep(0.5, 0.5 - softness, dist);
    
    COLOR = vec4(tex_color.rgb, tex_color.a * mask);
}
