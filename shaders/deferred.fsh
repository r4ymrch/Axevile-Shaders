#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;

#include "/lib/uniforms.glsl"
#include "/lib/util.glsl"
#include "/lib/ao.glsl"

void main() {
	float dither = texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).r;
	float ao = getAmbientOcclusion(dither);

	/* DRAWBUFFERS:4 */
	gl_FragData[0] = vec4(ao, 0.0, 0.0, 1.0);
}