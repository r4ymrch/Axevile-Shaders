/* 
* Modiefied ambient occlusion functions based from Capt Tatsu BSL Shaders
* https://capttatsu.com/bslshaders/
*/

const vec2 sampleOffsets[4] = vec2[4](
	vec2( 1.5,  0.5),
	vec2(-0.5,  1.5),
	vec2(-1.5, -0.5),
	vec2( 0.5, -1.5)
);

float getLD(float depth) {
  depth = depth * 2.0 - 1.0; 
  vec2 zw = depth * gbufferProjectionInverse[2].zw + gbufferProjectionInverse[3].zw;
  return -zw.x / zw.y;
}

float ambientOcclusion(float dither) {
	// for performance reasons
  const float TWO_PI = 6.28318530717959;
	const float INV_SQRT2 = 0.70710678118; // 1.0 / sqrt(2.0)

	float z = texture2D(depthtex0, texCoord).r;
	if (z == 1.0) return 1.0;
	
	float lz = getLD(z);
  float distanceScale = max(lz, 2.5);
	
	vec2 scale = ssao_radius * vec2(1.0 / aspectRatio, 1.0) * (gbufferProjection[1][1] / 1.37) / distanceScale;
  vec2 baseOffset = vec2(cos(dither * TWO_PI), sin(dither * TWO_PI));
  
	float ao = 0.0;
	for (int i = 0; i < 4; i++) {
    float currentStep = 0.2475 * float(i) + 0.01;
		vec2 offset = baseOffset * currentStep * scale;

    float angle = 0.0; 
    float dist = 0.0;
		for (int j = 0; j < 2; j++) {
			float sampleDepth = getLD(texture2D(depthtex0, texCoord + offset).r);
      float deltaZ = lz - sampleDepth;
			float aoSample = deltaZ * 3.0 / currentStep; 

			angle += clamp(0.5 - aoSample, 0.0, 1.0);
			dist += clamp(0.25 * aoSample - 1.0, 0.0, 1.0);
			offset = -offset;
		}
		
		ao += clamp(angle + dist, 0.0, 1.0);
		baseOffset = vec2(baseOffset.x - baseOffset.y, baseOffset.x + baseOffset.y) * INV_SQRT2;
	}

	return clamp(ao * 0.25, 0.0, 1.0);
}

float getAmbientOcclusion(float z) {
	float ao = 0.0;
	float tw = 0.0;
	float lz = getLD(z);
	
  for (int i = 0; i < 4; i++) {
		vec2 sampleOffset = sampleOffsets[i] / vec2(viewWidth, viewHeight);
		vec2 depthOffset = sampleOffsets[i] / vec2(viewWidth, viewHeight);
		
		float samplez = getLD(texture2D(depthtex0, texCoord + depthOffset).r);
		float wg = max(1.0 - 4.0 * abs(lz - samplez), 0.00001);
		
		ao += texture2D(colortex4, texCoord + sampleOffset).r * wg;
		tw += wg;
	}

  if (tw > 0.0001) {
    ao /= tw;
  } else {
    ao = texture2D(colortex4, texCoord).r;
  }
	
	return pow(ao, ssao_strength);
}