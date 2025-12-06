#version 120

varying vec2 texCoord;

#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/lighting/ssao.glsl"

void main() {
  float dither = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).b;
  float ao = ambientOcclusion(dither);

  /* DRAWBUFFERS:4 */
  gl_FragData[0] = vec4(ao, 0, 0, 1);
}