#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;
varying vec3 sunVec;
varying vec3 upVec;

#include "/lib/uniforms.glsl"

void main() {
	texCoord = gl_MultiTexCoord0.xy;
	#include "/lib/sunvector.glsl"
	gl_Position = ftransform();
}