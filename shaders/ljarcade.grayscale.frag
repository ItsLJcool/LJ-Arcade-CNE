#pragma header
const float third = 1.0 / 3.0;
void main() {
	gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
  	gl_FragColor.rgb = vec3((gl_FragColor.r + gl_FragColor.g + gl_FragColor.b) * third);
}