shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform sampler2D tex_albedo : source_color;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float radius : hint_range(0.0, 10.0) = 0.5;
uniform float softness : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 albedo_tex = texture(tex_albedo, UV);
    
    float dist = distance(UV, vec2(0.5)) * 2.0;
    
    float mask = smoothstep(radius - softness, radius, dist);
    
    ALBEDO = albedo_tex.rgb * color.rgb;
    ALPHA = albedo_tex.a * mask * color.a;
}
