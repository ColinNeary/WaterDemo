shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    uv.x += sin(uv.y * 30.0 + TIME * 3.0) * 0.005 * intensity;
    vec4 scene = texture(screen_texture, uv);
    vec3 blue_tint = vec3(0.6, 0.85, 1.0);
    scene.rgb = mix(scene.rgb, scene.rgb * blue_tint, intensity * 0.6);
    COLOR = scene;
}
