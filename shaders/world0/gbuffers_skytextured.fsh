#version 120

varying vec2 texCoord, lmCoord;
varying vec4 tintColor;

uniform sampler2D texture;

#include "/lib/config.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

void main() {
  vec4 color = texture2D(texture, texCoord);

  // to linear
  color.rgb = pow(color.rgb , vec3(2.2));

  vec3 grayscale = vec3(luminance(color.rgb));
  color.rgb = mix(grayscale, color.rgb, 2.0);

  color.a *= 1.0 - rainStrength;

  /* DRAWBUFFERS:0 */
  #ifdef ROUNDED_SUNMOON
    gl_FragData[0] = vec4(0.0, 0.0, 0.0, 0.0);
  #else
    gl_FragData[0] = color;
  #endif // ROUNDED_SUNMOON
}