#version 120

#include "/lib/settings.glsl"

attribute vec3 mc_Entity;
attribute vec2 mc_midTexCoord;

varying vec2 lmCoord;
varying vec2 texCoord;
varying vec3 normal;
varying vec3 alphaTest;
varying vec4 glcolor;

#include "/lib/uniforms.glsl"

void main() {
	vec3 sunVec, upVec;
	#include "/lib/sunvector.glsl"

	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	normal = normalize(gl_NormalMatrix * gl_Normal);
	glcolor = gl_Color;

	float NdotL = clamp(dot(normal, sunVec), 0.0, 1.0) * clamp(dot(sunVec, upVec) * 3.0, 0.0, 1.0);

	if (mc_Entity.x == 1.0) {
		alphaTest.x = 1.0;
		if (texCoord.y > mc_midTexCoord.y) {
			glcolor.rgb *= mix(0.65, 1.0, max(NdotL, lmCoord.x));
		}
	}

	if (mc_Entity.x == 2.0) {
		alphaTest.y = 1.0;
	}
	
	gl_Position = ftransform();
}