#version 120

#include "/lib/settings.glsl"

varying vec3 viewPos;
varying vec3 sunVec;
varying vec3 upVec;

#include "/lib/uniforms.glsl"

void main() {
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#include "/lib/sunvector.glsl"
	gl_Position = ftransform();
}