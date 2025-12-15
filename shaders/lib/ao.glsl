/* 
* Modiefied ambient occlusion functions based from Capt Tatsu BSL Shaders
* https://capttatsu.com/bslshaders/
*/

float getAmbientOcclusion(float dither) {
  const float TWO_PI = 6.28318530717959;
	const float INV_SQRT2 = 0.70710678118; // 1.0 / sqrt(2.0)

	float depth = texture2D(depthtex0, texCoord).r;
	if (depth == 1.0) {
		return 1.0;
	}
	
	float ld = getLD(depth);
  float distScale = max(ld, 2.5);

  const float radius = 0.35;
	
	vec2 scale = radius * vec2(1.0 / aspectRatio, 1.0) * (gbufferProjection[1][1] / 1.37) / distScale;
  vec2 baseOffset = vec2(cos(dither * TWO_PI), sin(dither * TWO_PI));
  
	float ao = 0.0;
	for (int i = 0; i < 4; i++) {
    float currentStep = 0.2475 * float(i) + 0.01;
		vec2 offset = baseOffset * currentStep * scale;

    float angle = 0.0; 
    float dist = 0.0;
		for (int j = 0; j < 2; j++) {
			float sampleDepth = getLD(texture2D(depthtex0, texCoord + offset).r);
      
      float dz = ld - sampleDepth;
			float aoSample = dz * (0.7 / radius) / currentStep; 

			angle += clamp(0.5 - aoSample, 0.0, 1.0);
			dist += clamp(0.25 * aoSample - 1.0, 0.0, 1.0);
			offset = -offset;
		}
		
		ao += clamp(angle + dist, 0.0, 1.0);
		baseOffset = vec2(baseOffset.x - baseOffset.y, baseOffset.x + baseOffset.y) * INV_SQRT2;
	}

	return clamp(ao * 0.25, 0.0, 1.0);
}