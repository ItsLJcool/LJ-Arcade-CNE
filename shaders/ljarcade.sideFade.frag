#pragma header

const float fadePixels;

void main() {
    gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    gl_FragColor *= smoothstep(openfl_TextureCoordv.x, 0.0, fadePixels / openfl_TextureSize.x);
}