#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;
varying vec3 sunVec;
varying vec3 upVec;

#include "/lib/uniforms.glsl"
#include "/lib/util.glsl"
#include "/lib/common.glsl"
#include "/lib/projection.glsl"
#include "/lib/sky.glsl"
#include "/lib/fog.glsl"

void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;

	float depth = texture2D(depthtex0, texCoord).r;
	vec3 viewPos = toView(texCoord, depth);

	if (depth < 1.0) {
		float fogFac = GetFogFactor(viewPos);

		vec3 fogColor = getSkyFog(normalize(viewPos)).rgb;
		fogColor = pow(fogColor, vec3(2.2));
		
		color = mix(color, fogColor, fogFac);
	}

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}