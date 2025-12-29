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

float timeAngle = float(worldTime) * 4.167e-5;
vec3 lightVec = (timeAngle < 0.5325 || timeAngle > 0.9675) ? sunVec : -sunVec;

#include "/lib/projection.glsl"
#include "/lib/distort.glsl"
#include "/lib/shadows.glsl"
#include "/lib/fog.glsl"

float getSubSurface(vec3 viewPos, vec2 alphaTest) {
	float viewDotSun = max(dot(normalize(viewPos), sunVec), 0.0);
	return pow(viewDotSun, 3.0) * max(alphaTest.x, alphaTest.y);
}

vec3 calcLighting(vec3 color, vec3 viewPos, vec3 worldPos, vec3 normal, vec3 alphaTest, vec2 uv1, float depth) {
	float SoU = dot(sunVec, upVec);
	float MoU = dot(-sunVec, upVec);

	float skyLight = pow(uv1.y, 3.0);
	
	vec3 ambientLight = zenithCol;
	ambientLight *= 1.5 - 1.0 * moonVisibility;
  
	ambientLight *= 1.0 + 0.75 * rainStrength;
  ambientLight *= skyLight;

	float NdotL = clamp(2.0 * dot(normal, lightVec), 0.0, 1.0);
	if (alphaTest.x > 0.0 || alphaTest.y > 0.0) {
		NdotL = 0.5 + 0.25 * sunVisibility;
	}

	vec3 sunLight = pow(sunLightCol, vec3(2.2)) * 6.0 * clamp(SoU * 3.0, 0.0, 1.0);
	vec3 moonLight = pow(moonCol, vec3(2.2)) * vec3(0.25, 0.5, 1.0) * clamp(MoU * 3.0, 0.0, 1.0);

	vec3 sunMoonLight = (sunLight + moonLight);
	
	float subsurface = getSubSurface(viewPos, alphaTest.xy);
  sunMoonLight *= mix(1.0, 3.0, subsurface);
	
	sunMoonLight *= uv1.y;
  sunMoonLight *= NdotL;
  sunMoonLight *= getShadows(worldPos, normal, alphaTest);

	sunMoonLight *= 1.0 - rainStrength;

	vec3 blockLight = vec3(1.0, 0.9, 0.8) * (
    0.2 * uv1.x +
    0.4 * pow(uv1.x, 2.0) +
    0.4 * pow(uv1.x, 5.0) +
    0.6 * pow(uv1.x, 7.0)
  );

  blockLight += vec3(1.0, 0.5, 0.3) * 16.0 * pow(uv1.x, 24.0);

	color *= sunMoonLight + ambientLight + blockLight;

	if (isEyeInWater == 1) {
    float underwaterDepth = exp(-(1.0 - uv1.y) * 6.0);
    float underwaterDepth2 = exp(-(1.0 - uv1.y) * 2.0);
    color *= mix(vec3(0.0, 1.0, 1.0), vec3(1.2), underwaterDepth);
    
    float distanceFog = GetUnderwaterFogFactor(viewPos);
		vec3 waterFogColor = vec3(0.2, 0.8, 1.0) * mix(0.15, 0.25, sunVisibility);
    waterFogColor = mix(waterFogColor, vec3(luminance(waterFogColor)) * vec3(0.65, 0.8, 1.0), rainStrength);
    waterFogColor = pow(waterFogColor, vec3(2.2));
    
    color = mix(waterFogColor, color, underwaterDepth2);
    color = mix(color, waterFogColor, distanceFog);
  }

	return color;
}

void main() {
  vec3 outColor = texture2D(colortex0, uv0).rgb;
  vec3 uv1 = texture2D(colortex2, uv0).rgb;
  vec3 vNormal = normalize(texture2D(colortex1, uv0).rgb * 2.0 - 1.0);
  vec3 alphaTest = texture2D(colortex3, uv0).rgb;

  float depth = texture2D(depthtex0, uv0).r;
	vec3 viewPos = toView(uv0, depth);
  vec3 worldPos = toWorld(viewPos);

  if (depth < 1.0) {
		outColor = calcLighting(outColor, viewPos, worldPos, vNormal, alphaTest, uv1.xy, depth);
	}

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(outColor, 1.0);
}

#endif // FSH