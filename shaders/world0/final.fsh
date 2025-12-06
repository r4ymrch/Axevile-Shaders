#version 120

varying vec2 texCoord;

#include "/lib/common.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

vec3 Lottes(vec3 x) {
  const vec3 a = vec3(1.6);
  const vec3 d = vec3(0.977);
  const vec3 hdrMax = vec3(8);
  const vec3 midIn = vec3(0.18);
  const vec3 midOut = vec3(0.267);

  const vec3 b = (-pow(midIn, a) + pow(hdrMax, a) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
  const vec3 c = (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);

  return pow(x, a) / (pow(x, a * d) * b + c);
}

vec3 finalColor(vec3 color) {
  color *= 1.2;
  color = Lottes(color);
  color = pow(color, vec3(1 / 2.2));
  return color;
}

void main() {
  vec3 color = texture2D(colortex0, texCoord).rgb;

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(finalColor(color), 1);
}