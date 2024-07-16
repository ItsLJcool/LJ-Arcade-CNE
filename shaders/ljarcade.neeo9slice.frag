#pragma header

// Image 9-slicing in fragment shader.
// Feel free to share and use anywhere.
// https://www.shadertoy.com/view/WldSDX

// borders in pixels, x = left, y = bottom, z = right, w = top
#define B vec4(9., 9., 9.,9.)

uniform sampler2D border;
uniform sampler2D background;
uniform vec2 borderSize;
uniform vec2 backgroundSize;

vec2 uv9slice(vec2 uv, vec2 s, vec4 b)
{
    vec2 t = clamp((s * uv - b.xy) / (s - b.xy - b.zw), 0., 1.);
    return mix(uv * s, 1. - s * (1. - uv), t);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize.xy;

    vec2 uvo = uv;
    vec2 ts = borderSize;
    // scaling factor
    // probably available as uniform irl
    vec2 s = openfl_TextureSize.xy / ts;

    // border by texture size, shouldn't be > .5
    // probably available as uniform irl
    vec4 b = min(B / ts.xyxy, vec4(.499));
    uv = uv9slice(uv, s, b);

    vec4 col = vec4(texture2D(border, uv).rgba);

    if(fragCoord.x > 6.0 && fragCoord.y > 6.0 &&
        fragCoord.x < openfl_TextureSize.x - 6.0 && fragCoord.y < openfl_TextureSize.y - 6.0) {
        col = texture2D(background, fragCoord/backgroundSize.xy);
    }

    gl_FragColor = col;
}