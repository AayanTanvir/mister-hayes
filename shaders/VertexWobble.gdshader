shader_type spatial;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec2 snap_resolution = vec2(320.0, 180.0);

void vertex() {
    vec4 clip_pos = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    vec2 ndc = clip_pos.xy / clip_pos.w;

    vec2 screen_pos = (ndc * 0.5 + 0.5) * snap_resolution;
    screen_pos = floor(screen_pos + 0.5);

    ndc = (screen_pos / snap_resolution - 0.5) * 2.0;
    clip_pos.xy = ndc * clip_pos.w;
    POSITION = clip_pos;
}

void fragment() {
    vec4 tex = texture(albedo_texture, UV) * albedo_color;
    ALBEDO = tex.rgb;
}