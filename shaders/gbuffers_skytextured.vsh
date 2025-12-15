#version 120

#include "/lib/settings.glsl"

varying vec2 texcoord;
varying vec3 viewPos;
varying vec3 sunVec;
varying vec3 upVec;
varying vec4 glcolor;

#include "/lib/uniforms.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#include "/lib/sunvector.glsl"
	glcolor = gl_Color;
	gl_Position = ftransform();
}