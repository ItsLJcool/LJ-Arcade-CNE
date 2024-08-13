#pragma header
uniform float mulX;
uniform float mulY;
void main() {
	vec2 uv = openfl_TextureCoordv;
	uv -= vec2(0.5, 0.5);
	uv *= vec2(mulX, mulY);
	uv += vec2(0.5, 0.5);
	gl_FragColor = texture2D(bitmap, uv);
}