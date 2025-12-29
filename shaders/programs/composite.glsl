#include "/lib/settings.glsl"

#ifdef VSH

varying vec2 uv0;
varying vec3 sunVec, upVec;

#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

void main() {
  uv0 = gl_MultiTexCoord0.xy;
  #include "/lib/src/sunvector.glsl"
  gl_Position = ftransform();
}

#endif // VSH

#ifdef FSH

varying vec2 uv0;
varying vec3 sunVec, upVec;

#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/common.glsl"
#include "/lib/projection.glsl"
#include "/lib/sky.glsl"
#include "/lib/fog.glsl"

void main() {
  vec3 outColor = texture2D(colortex0, uv0).rgb;

  float depth = texture2D(depthtex0, uv0).r;
	vec3 viewPos = toView(uv0, depth);

	if (depth < 1.0) {
		float fogFac = GetFogFactor(viewPos);

		vec3 fogColor = getSkyFog(normalize(viewPos)).rgb;
		fogColor = pow(fogColor, vec3(2.2));
		
		outColor = mix(outColor, fogColor, fogFac);
	}

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}

#endif // FSH