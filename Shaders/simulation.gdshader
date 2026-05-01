shader_type canvas_item;

uniform sampler2D sim_tex;
uniform sampler2D col_tex;

uniform float phase = 0.2;
uniform float attenuation = 0.999;
uniform float deltaUV = 3.0;

// Wave controls (expose these to Inspector / UI sliders)
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.08;
uniform float wave_frequency : hint_range(1.0, 20.0) = 6.0;
uniform float wave_speed     : hint_range(0.0, 5.0)  = 1.2;

void vertex() {}

void fragment() {
    float dv = 1.0 / 514.0;
    float du = 1.0 / 514.0;
    vec3 duv = vec3(du, dv, 0) * deltaUV;

    vec3 c = texture(sim_tex, UV).rgb;

    // --- Discrete wave equation (ripple physics) ---
    float p = (2.0 * c.r - c.g + phase * (
        texture(sim_tex, UV - duv.zy).r +
        texture(sim_tex, UV + duv.zy).r +
        texture(sim_tex, UV - duv.xz).r +
        texture(sim_tex, UV + duv.xz).r - 4.0 * c.r)) * attenuation;

    // --- Sine wave injection ---
    // Two waves at different angles so it looks like open water, not a pool
    float wave1 = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float wave2 = sin((UV.x * 0.7 + UV.y * 0.7) * wave_frequency * 0.8 + TIME * wave_speed * 0.9) * wave_amplitude * 0.6;
    p += wave1 + wave2;

    // --- Collision detection ---
    vec2 col_uv = vec2(UV.x, 1.0 - UV.y);
    float col = texture(col_tex, col_uv).r;
    float prevCol = texture(sim_tex, UV).b;

    if (col > 0.0 && prevCol == 0.0) {
        p += col * 0.5;
    }
    if (prevCol > 0.0 && col == 0.0) {
        p -= prevCol * 0.5;
    }

    COLOR = vec4(p, c.r, col, 1);
}