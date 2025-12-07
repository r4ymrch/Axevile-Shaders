#version 120

varying vec2 texCoord;

#include "/lib/config.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

#ifdef SSAO
  #include "/lib/lighting/ssao.glsl"
#endif // SSAO

void main() {
  float z = texture2D(depthtex0, texCoord).r;
  vec3 color = texture2D(colortex0, texCoord).rgb;

  #ifdef SSAO
    color *= getAmbientOcclusion(z);
  #endif // SSAO

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(color, 1.0);
}