#pragma header

// Used for editors (faster)

#define getTexture textureCam

#define iResolution openfl_TextureSize

uniform float uBlur;
uniform float uBrightness;
uniform float entropy;

vec4 getColor(vec2 pos) {
	vec2 ps = (pos);
	ps = clamp(ps, vec2(0.0), vec2(1.0));//1.0 - (1.0 / iResolution.xy));
	return flixel_texture2D(bitmap, (ps));
}

vec2 random(vec2 p) {
	p = vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3)));
	return fract(sin(p)*4375.5);
}

void main() {
	vec2 camPos = (openfl_TextureCoordv);
	if (camPos.x < 0.0 || camPos.x > 1.0 || camPos.y < 0.0 || camPos.y > 1.0)
		return;

	vec2 blur = vec2(uBlur) * vec2(1.0, iResolution.x / iResolution.y);

	vec4 a = getColor(camPos+(random(camPos + entropy)*blur - blur / 2.0)) * uBrightness;
	a += getColor(camPos+(random(camPos+0.1 + entropy)*blur - blur / 2.0)) * uBrightness;
	//a += getColor(camPos+(random(camPos+0.2)*blur - blur / 2.0)) * uBrightness;
	//a += getColor(camPos+(random(camPos+0.3)*blur - blur / 2.0)) * uBrightness;
	gl_FragColor = a / 2.0;
}