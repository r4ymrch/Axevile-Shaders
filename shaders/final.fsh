#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;

/*
const int colortex0Format = R11F_G11F_B10F;
*/

#include "/lib/tonemap.glsl"

void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;

	color = reinhard(color);
  color = pow(color, vec3(1.0 / 2.2));

	gl_FragColor = vec4(color, 1.0);
}