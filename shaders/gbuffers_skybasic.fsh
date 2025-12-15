#version 120

#include "/lib/settings.glsl"

varying vec3 viewPos;
varying vec3 sunVec;
varying vec3 upVec;

#include "/lib/uniforms.glsl"
#include "/lib/util.glsl"
#include "/lib/common.glsl"
#include "/lib/sky.glsl"

void main() {
	vec3 noPos = normalize(viewPos);
	vec4 color = getSky(noPos);

	color.rgb = pow(color.rgb, vec3(2.2));

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
}