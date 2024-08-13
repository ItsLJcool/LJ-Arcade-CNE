#pragma header

#define PRIDE 0
#define TRANS 1

uniform int flag;

void main() {
    vec2 uv = getCamPos(openfl_TextureCoordv);
    vec4 color = textureCam(bitmap, uv);

    if(flag == PRIDE) {
        if(uv.y < 1.0/6.0) color.rgb = vec3(1.0, 0.0, 0.0) * color.a;
        else if(uv.y < 2.0/6.0) color.rgb = vec3(1.0, 0.54, 0.0) * color.a;
        else if(uv.y < 3.0/6.0) color.rgb = vec3(1.0, 1.0, 0.0) * color.a;
        else if(uv.y < 4.0/6.0) color.rgb = vec3(0.0, 0.5, 0.0) * color.a;
        else if(uv.y < 5.0/6.0) color.rgb = vec3(0.0, 0.0, 1.0) * color.a;
        else if(uv.y < 6.0/6.0) color.rgb = vec3(0.54, 0.0, 1.0) * color.a;
    } else if(flag == TRANS) {
        if(uv.y < 1.0/5.0) color.rgb = vec3(0.333,0.803,0.98) * color.a;
        else if(uv.y < 2.0/5.0) color.rgb = vec3(0.968,0.658,0.721) * color.a;
        else if(uv.y < 3.0/5.0) color.rgb = vec3(1.0, 1.0, 1.0) * color.a;
        else if(uv.y < 4.0/5.0) color.rgb = vec3(0.968,0.658,0.721) * color.a;
        else if(uv.y < 5.0/5.0) color.rgb = vec3(0.333,0.803,0.98) * color.a;
    }

    gl_FragColor = color;
}