#version 120

varying vec2 texCoord, lmCoord;
varying vec4 tintColor;

void main() {
  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  tintColor = gl_Color;

  gl_Position = ftransform();
}