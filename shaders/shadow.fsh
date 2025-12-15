#version 120

varying vec2 texCoord;

uniform sampler2D texture;

void main() {
  gl_FragData[0] = texture2D(texture, texCoord);
}