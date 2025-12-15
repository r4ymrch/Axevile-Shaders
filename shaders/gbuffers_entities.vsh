#version 120

attribute vec3 mc_Entity;

varying vec2 lmCoord;
varying vec2 texCoord;
varying vec3 normal;
varying vec3 alphaTest;
varying vec4 glcolor;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	normal = normalize(gl_NormalMatrix * gl_Normal);
	glcolor = gl_Color;

	if (mc_Entity.x == 1.0) {
		alphaTest.x = 1.0;
	}

	if (mc_Entity.x == 2.0) {
		alphaTest.y = 1.0;
	}
	
	gl_Position = ftransform();
}