const vec2 shadowOffsets[8] = vec2[8](
  vec2(-0.04117257, -0.1597612 ),
  vec2( 0.06731031, -0.4353096 ),
  vec2(-0.206701,   -0.4089882 ),
  vec2( 0.1857469,  -0.2327659 ),
  vec2(-0.2757695,  -0.159873  ),
  vec2(-0.2301117,   0.1232693 ),
  vec2( 0.05028719,  0.1034883 ),
  vec2( 0.236303,    0.03379251)
);

vec2 sampleBlur(int i) {
  float blueNoise = texture2D(noisetex, gl_FragCoord.xy * invNoiseRes).r;
	return rotmat(blueNoise * 6.28) * shadowOffsets[i];
}

float getBasicShadow(sampler2DShadow shadowTex, vec3 shadowPos) {
	return shadow2D(shadowTex, shadowPos).x;
}

float getFilteredShadow(sampler2DShadow shadowTex, vec3 shadowPos, float blurRadius) {
  float shadowMap = 0.0;
  for (int i = 0; i < 4; i++) {
    vec2 sampleOffset = sampleBlur(i) * blurRadius;
    shadowMap += getBasicShadow(shadowTex, vec3(shadowPos.xy + sampleOffset, shadowPos.z));
  }
  return shadowMap * 0.25;
}

vec3 getShadows(vec3 worldPos, vec3 normal, vec3 alphaTest) {
  vec3 wNormal = mat3(gbufferModelViewInverse) * normal;

  float NdotL = clamp(dot(normal, lightVec), 0.0, 1.0);
	float cDist = sqrt(dot(worldPos, worldPos));
  vec3 bias = wNormal * min(0.05 + cDist * 0.005, 0.5) * (2.0 - max(NdotL, 0.0));

  bias *= (alphaTest.x > 0.0 || alphaTest.y > 0.0) ? 0.25 : 1.0;

  vec3 shadowPos = toShadow(worldPos + bias);
  shadowPos = distortShadow(shadowPos);
  
  if (alphaTest.x > 0.0) {
    shadowPos.z -= 0.0015;
  }
  
  if (alphaTest.x > 0.0 || alphaTest.y > 0.0) {
    shadowPos.z -= 0.0001;
  }
  
  shadowPos = shadowPos * 0.5 + 0.5;

  vec3 totalShadow = vec3(1.0);
  
  float blurRadius = 4.0 / shadowMapResolution;
  if (alphaTest.y > 0.0) {
    blurRadius *= 1.5;
  }

  float shadowMap0 = getFilteredShadow(shadowtex0, shadowPos, blurRadius);
  float shadowMap1 = getFilteredShadow(shadowtex1, shadowPos, blurRadius);
  
  vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy);
  
  if (shadowMap0 < 1.0) {
    shadowColor.rgb = texture2D(shadowcolor0, shadowPos.xy).rgb * shadowMap1;
  }
    
  shadowColor.rgb = mix(vec3(1.0), shadowColor.rgb, shadowColor.a);
  shadowColor.rgb *= pow(shadowColor.rgb, vec3(3.0));

  totalShadow *= clamp(shadowColor.rgb * (shadowMap1 - shadowMap0) + shadowMap0, 0.0, 1.0);

  return totalShadow;
}