#include "/lib/settings.glsl"

#ifdef VSH

attribute vec3 mc_Entity;

varying float waterMask;
varying vec2 uv0;

#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/distort.glsl"

void main() {
  uv0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  waterMask = mc_Entity.x == 3.0 ? 1.0 : 0.0;
  
  vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();
	gl_Position = shadowProjection * shadowModelView * position;
  gl_Position.xyz = distortShadow(gl_Position.xyz);
}

#endif // VSH

#ifdef FSH

varying float waterMask;
varying vec2 uv0;

uniform sampler2D texture;

void main() {
  gl_FragData[0] = waterMask > 0.0 ? vec4(0.0, 0.0, 0.0, 0.0) : texture2D(texture, uv0);
}

#endif // FSH