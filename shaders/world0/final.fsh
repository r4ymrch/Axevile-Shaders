#version 120

varying vec2 texCoord;

#include "/lib/config.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

vec3 finalColor(vec3 color) {
  color *= 1.2;
  color = color / (0.9813 * color + 0.1511);
  return color;
}

void main() {
  vec3 color = texture2D(colortex0, texCoord).rgb;

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(finalColor(color), 1.0);
}