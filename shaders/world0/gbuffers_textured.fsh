#version 120

varying vec2 texCoord, lmCoord;
varying vec4 tintColor;

uniform sampler2D texture;

void main() {
  vec4 color = texture2D(texture, texCoord) * tintColor;

  // to linear
  color.rgb = pow(color.rgb , vec3(2.2));

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = color;
}