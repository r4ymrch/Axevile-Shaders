#version 120

varying vec2 texCoord;

#include "/lib/config.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

#ifdef SSAO
  #include "/lib/lighting/ssao.glsl"
#endif // SSAO

void main() {
  #ifdef SSAO
    float dither = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).r;
    float ao = ambientOcclusion(dither);
  #else
    float ao = 0.0;
  #endif // SSAO

  /* DRAWBUFFERS:4 */
  gl_FragData[0] = vec4(ao, 0.0, 0.0, 1.0);
}