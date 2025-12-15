#version 120

#include "/lib/settings.glsl"

varying vec2 texCoord;
varying vec3 sunVec;
varying vec3 upVec;

#include "/lib/uniforms.glsl"
#include "/lib/util.glsl"
#include "/lib/common.glsl"
#include "/lib/projection.glsl"
#include "/lib/distort.glsl"
#include "/lib/shadows.glsl"

const vec2 aoOffsets[4] = vec2[4](
	vec2( 1.5,  0.5),
	vec2(-0.5,  1.5),
	vec2(-1.5, -0.5),
	vec2( 0.5, -1.5)
);

float getAmbientOcclusion(float depth, float strength) {
	float ao = 0.0;
	float tw = 0.0;
	float ld = getLD(depth);
	
  for (int i = 0; i < 4; i++) {
		vec2 sampleOffset = aoOffsets[i] / vec2(viewWidth, viewHeight);
		vec2 depthOffset = aoOffsets[i] / vec2(viewWidth, viewHeight);
		
		float sampleDepth = getLD(texture2D(depthtex0, texCoord + depthOffset).r);
		float wg = max(1.0 - 4.0 * abs(ld - sampleDepth), 0.00001);
		
		ao += texture2D(colortex4, texCoord + sampleOffset).r * wg;
		tw += wg;
	}

  if (tw > 0.0001) {
    ao /= tw;
  } else {
    ao = texture2D(colortex4, texCoord).r;
  }

	ao = mix(1.0, pow(ao, strength), clamp(strength, 0.0, 1.0));
	
	return ao;
}

float getSubSurface(vec3 viewPos, vec2 alphaTest) {
	float viewDotSun = max(dot(normalize(viewPos), sunVec), 0.0);
	return pow(viewDotSun, 3.0) * max(alphaTest.x, alphaTest.y);
}

vec3 calcLighting(vec3 color, vec3 viewPos, vec3 worldPos, vec3 normal, vec3 alphaTest, vec2 lightMap, float depth) {
	float SoU = dot(sunVec, upVec);
	float MoU = dot(-sunVec, upVec);

	float skyLight = pow(lightMap.y, 3.0);
	
	vec3 ambientLight = zenithCol;
	ambientLight *= 1.75 - 0.75 * sunVisibility;
	ambientLight *= 1.0 - 0.95 * moonVisibility;
  
	ambientLight *= 1.0 + 0.75 * rainStrength;
  ambientLight *= skyLight;
	ambientLight *= getAmbientOcclusion(depth, 1.5);

	float NdotL = clamp(dot(normal, lightVec), 0.0, 1.0);
	if (alphaTest.x > 0.0 || alphaTest.y > 0.0) {
		NdotL = 0.5 + 0.25 * sunVisibility;
	}

	vec3 sunLight = pow(sunLightCol, vec3(2.2)) * 6.0 * clamp(SoU * 3.0, 0.0, 1.0);
	vec3 moonLight = pow(moonCol, vec3(2.2)) * vec3(0.25, 0.5, 1.0) * clamp(MoU * 3.0, 0.0, 1.0);

	vec3 sunMoonLight = (sunLight + moonLight);
	
	float subsurface = getSubSurface(viewPos, alphaTest.xy);
  sunMoonLight *= mix(1.0, 3.0, subsurface);
	
	sunMoonLight *= lightMap.y;
  sunMoonLight *= NdotL;
  sunMoonLight *= getShadows(worldPos, normal, alphaTest);

	sunMoonLight *= 1.0 - rainStrength;

	vec3 blockLight = vec3(1.0, 0.9, 0.8) * (
    0.2 * lightMap.x +
    0.4 * pow(lightMap.x, 2.0) +
    0.4 * pow(lightMap.x, 5.0) +
    0.6 * pow(lightMap.x, 7.0)
  );

  blockLight += vec3(1.0, 0.5, 0.3) * 16.0 * pow(lightMap.x, 24.0);

	color *= sunMoonLight + ambientLight + blockLight;

	return color;
}

void main() {
	vec2 lightMap = texture2D(colortex2, texCoord).rg;
	vec3 color = texture2D(colortex0, texCoord).rgb;
	vec3 vNormal = normalize(texture2D(colortex1, texCoord).rgb * 2.0 - 1.0);
	vec3 alphaTest = texture2D(colortex3, texCoord).rgb;

	float depth = texture2D(depthtex0, texCoord).r;
	vec3 viewPos = toView(texCoord, depth);
  vec3 worldPos = toWorld(viewPos);

	if (depth < 1.0) {
		color = calcLighting(color, viewPos, worldPos, vNormal, alphaTest, lightMap, depth);
	}

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}