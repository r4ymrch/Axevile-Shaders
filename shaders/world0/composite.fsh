#version 120

varying vec2 texCoord;
varying vec3 sunVector, lightVector, upVector;
varying float dayMixer, nightMixer;

#include "/lib/config.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

#ifdef CLOUDS
	#include "/lib/atmospherics/clouds.glsl"
#endif // BLOCKY_CLOUDS

void main() {
  vec3 color = texture2D(colortex0, texCoord).rgb;

  float z = texture2D(depthtex0, texCoord).r;
	vec3 viewPos = cameraSpaceToViewSpace(texCoord, z);
	vec3 worldPos = viewSpaceToWorldSpace(viewPos);

	#ifdef CLOUDS
		if (z == 1) {
			vec3 worldSunVec = mat3(gbufferModelViewInverse) * lightVector;

			float dither = texture2D(noisetex, gl_FragCoord.xy * invNoiseResolution).r;
			vec4 clouds = getVolumetricClouds(normalize(worldPos), worldSunVec, dither);

			color = color * clouds.a + clouds.rgb;
		}
	#endif // BLOCKY_CLOUDS

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(color, 1.0);
}