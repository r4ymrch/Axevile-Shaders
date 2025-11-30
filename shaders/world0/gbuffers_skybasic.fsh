#version 120

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;

float dayMixer = clamp(dot(sunVector, upVector) * 1.5, 0, 1);
float nightMixer = clamp(dot(-sunVector, upVector) * 8, 0, 1);

#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/atmospherics/sky.glsl"

void main() {
  vec3 normalizedViewPos = normalize(viewPos);
  vec4 color = calculateSkyScattering(normalizedViewPos);
  
  // to linear
  color.rgb = pow(color.rgb, vec3(2.2));
  
  /* DRAWBUFFERS:0 */
  gl_FragData[0] = color;
}