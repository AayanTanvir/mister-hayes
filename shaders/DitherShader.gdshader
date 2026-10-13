shader_type canvas_item;

uniform float levels : hint_range(1.0, 100.0, 1.0) = 70.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;

const float BAYER[16] = float[16](
     0.0,  8.0,  2.0, 10.0,
    12.0,  4.0, 14.0,  6.0,
     3.0, 11.0,  1.0,  9.0,
    15.0,  7.0, 13.0,  5.0
);

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    // which pixel of the low-res image are we on?
    vec2 px = floor(UV / TEXTURE_PIXEL_SIZE);
    int x = int(mod(px.x, 4.0));
    int y = int(mod(px.y, 4.0));

    // a per-pixel nudge between about -0.5 and +0.5
    float threshold = (BAYER[y * 4 + x] + 0.5) / 16.0 - 0.5;

    col.rgb = floor(col.rgb * levels + 0.5 + threshold * dither_strength) / levels;
    COLOR = col;
}