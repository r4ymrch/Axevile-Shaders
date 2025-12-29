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
#include "/lib/distort.glsl"

float GetLightShaft(float dither) {
  float depth = texture2D(depthtex0, uv0).r;
  float linearDepth = (2.0 * near) / (far + near - depth * (far - near));
  float viewDistance = linearDepth * far * 0.5;
  
  float lightShaft = 0.0;
  for (int i = 0; i < 4; i++) {
    float currentDepth = exp2(i + dither) - 0.5;
    if (currentDepth > viewDistance) break;
    
    currentDepth = (far * (currentDepth - near)) / (currentDepth * (far - near));

    vec3 viewPos = toView(uv0, currentDepth);
    vec3 worldPos = toWorld(viewPos);

    vec3 lightShaftPos = toShadow(worldPos);
    lightShaftPos = distortShadow(lightShaftPos);
    lightShaftPos = lightShaftPos * 0.5 + 0.5;

    lightShaft += shadow2D(shadowtex1, lightShaftPos).x;
  }

  return clamp(lightShaft * 0.25, 0.0, 1.0);
}

void main() {
  vec3 outColor = texture2D(colortex0, uv0).rgb;

  float depth = texture2D(depthtex0, uv0).r;
	vec3 viewPos = toView(uv0, depth);

  float sunv = clamp(dot(sunVec, upVec) * 24.0, 0.0, 1.0);

  float mieg = (isEyeInWater == 1) ? 0.3 : 0.8;
  float str = (isEyeInWater == 1) ? 10.0 : 0.5;
  
  float sunLSVisibility = miePhase(dot(normalize(viewPos), sunVec), mieg) * str * (1.0 - 0.5 * sunVisibility) * sunv;
  float moonLSVisibility = miePhase(dot(normalize(viewPos), -sunVec), mieg) * str * (1.0 - sunv);
	
  float lsVisibility = sunLSVisibility + moonLSVisibility;

  float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).r;
  float baseLightShaft = GetLightShaft(blueNoise);
	baseLightShaft *= (1.0 - rainStrength);
	
  vec3 lightShaftColor = mix(sunLightCol, moonCol * 1.5, moonVisibility);
  lightShaftColor = pow(lightShaftColor, vec3(2.2)) * baseLightShaft;

  vec3 waterFogColor = vec3(0.2, 0.8, 1.0) * mix(0.15, 0.25, sunVisibility) - 0.1 * moonVisibility;
  if (isEyeInWater == 1) lightShaftColor = waterFogColor;
	
  outColor += lightShaftColor * baseLightShaft * lsVisibility;

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}

#endif // FSH