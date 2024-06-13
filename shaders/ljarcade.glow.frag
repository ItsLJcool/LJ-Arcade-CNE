#pragma header

uniform float glow = 0.2;
void main() {
    gl_FragColor = vec4(openfl_TextureCoordv.y * glow); // Higher = more opaque
}