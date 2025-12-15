#version 120

varying vec2 lmCoord;
varying vec2 texCoord;
varying vec3 normal;
varying vec3 alphaTest;
varying vec4 glcolor;

uniform sampler2D lightmap;
uniform sampler2D texture;

void main() {
	vec4 color = texture2D(texture, texCoord) * glcolor;
	vec3 encodedNormal = normal * 0.5 + 0.5;
	
	color.rgb = pow(color.rgb, vec3(2.2));

	/* DRAWBUFFERS:0123 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(encodedNormal, 1.0);
	gl_FragData[2] = vec4(lmCoord, 0.0, 1.0);
	gl_FragData[3] = vec4(alphaTest, 1.0);
}