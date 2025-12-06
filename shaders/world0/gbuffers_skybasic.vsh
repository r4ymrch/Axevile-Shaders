#version 120

varying vec3 viewPos;
varying vec3 sunVector, lightVector, upVector;
varying float dayMixer, nightMixer;

#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/sunVectors.glsl"

void main() {
  viewPos = projectAndDivide(gl_ModelViewMatrix, gl_Vertex.xyz);
  
  calculateSunVector(
    sunVector,
    lightVector,
    upVector
  );

  dayMixer = clamp(dot(sunVector, upVector) * 1.5, 0, 1);
  nightMixer = clamp(dot(-sunVector, upVector) * 8, 0, 1);

  gl_Position = ftransform();
}