#version 120

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;
varying float dayMixer, nightMixer;

#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/sunVectors.glsl"

void main() {
  texCoord = gl_MultiTexCoord0.xy;
  
  calculateSunVector(
    sunVector,
    lightVector,
    upVector
  );

  dayMixer = clamp(dot(sunVector, upVector) * 1.5, 0, 1);
  nightMixer = clamp(dot(-sunVector, upVector) * 8, 0, 1);

  gl_Position = ftransform();
}