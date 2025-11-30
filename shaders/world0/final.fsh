#version 120

varying vec2 texCoord;

#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/tonemaps.glsl"

void main() {
  vec3 color = texture2D(colortex0, texCoord).rgb;

  color = Tonemap(color);

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(color, 1);
}