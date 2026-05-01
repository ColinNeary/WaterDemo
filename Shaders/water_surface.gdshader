shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ── Textures ──────────────────────────────────────────────────────────────────
uniform sampler2D simulation : hint_default_black, filter_linear_mipmap, repeat_enable;

// ── Wave tuning ───────────────────────────────────────────────────────────────
uniform float wave_height    : hint_range(0.0, 2.0)  = 0.4;
uniform float texel_size     : hint_range(0.0005, 0.01) = 0.002; // 1/514 ≈ 0.00195

// ── Water appearance ──────────────────────────────────────────────────────────
uniform vec4  shallow_color  : source_color = vec4(0.05, 0.45, 0.65, 0.85);
uniform vec4  deep_color     : source_color = vec4(0.02, 0.18, 0.35, 0.95);
uniform float fresnel_power  : hint_range(1.0, 8.0)  = 4.0;
uniform float roughness_val  : hint_range(0.0, 1.0)  = 0.08;
uniform float specular_val   : hint_range(0.0, 1.0)  = 0.9;
uniform float normal_strength: hint_range(0.0, 5.0)  = 2.0;

// ── Helper: sample height from sim texture ────────────────────────────────────
float get_height(vec2 uv) {
    return texture(simulation, uv).r;
}

// =============================================================================
// VERTEX — displace geometry using simulation height field
// =============================================================================
void vertex() {
    // Keep displacement very subtle — ripple effect is mostly in fragment
    float h = get_height(UV);
    VERTEX.y += h * wave_height;  // set wave_height to ~0.03 in Inspector
}

// =============================================================================
// FRAGMENT — shade the water surface
// =============================================================================

void fragment() {
    float texel = texel_size;

    float hL = get_height(UV + vec2(-texel, 0.0));
    float hR = get_height(UV + vec2( texel, 0.0));
    float hD = get_height(UV + vec2(0.0, -texel));
    float hU = get_height(UV + vec2(0.0,  texel));

    // This normal variation is what creates the visible ripple rings
    vec3 frag_normal = normalize(vec3(
        (hL - hR) * normal_strength,
        1.0,
        (hD - hU) * normal_strength
    ));
    NORMAL_MAP = frag_normal * 0.5 + 0.5;

    float NdotV  = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float fresnel = pow(1.0 - NdotV, fresnel_power);

    ALBEDO    = mix(shallow_color.rgb, deep_color.rgb, fresnel);
    ROUGHNESS = roughness_val;
    SPECULAR  = specular_val;
    METALLIC  = 0.0;
    ALPHA     = mix(shallow_color.a, deep_color.a, fresnel);
}