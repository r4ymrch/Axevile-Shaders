#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;

#include "/lib/uniforms.glsl"
#include "/lib/util.glsl"
// #include "/lib/common.glsl"
#include "/lib/projection.glsl"
#include "/lib/distort.glsl"

void main() {
  texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  
  vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();
	gl_Position = shadowProjection * shadowModelView * position;
  gl_Position.xyz = distortShadow(gl_Position.xyz);
}