#version 120

#include "/lib/settings.glsl"

varying vec2 texcoord;
varying vec3 viewPos;
varying vec3 sunVec;
varying vec3 upVec;
varying vec4 glcolor;

uniform sampler2D texture;

#include "/lib/uniforms.glsl"
#include "/lib/common.glsl"
#include "/lib/util.glsl"

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	color.rgb = pow(color.rgb, vec3(2.2));
	vec3 grayscale = vec3(luma(color.rgb));
  color.rgb = mix(grayscale, color.rgb, 1.5);

	float VoU = dot(normalize(viewPos), upVec);
	float horizonFall = fogify(max(VoU + h_Offset + 0.05, 0.0), HORIZON_DENSITIES * 0.001);
  color.a *= (1.0 - horizonFall) * (1.0 - rainStrength);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}