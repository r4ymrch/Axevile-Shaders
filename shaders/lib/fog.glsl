float GetFogFactor(vec3 viewPos) {
  vec3 worldPos = toWorld(viewPos) + cameraPosition;

	float fogDensity = mix(6.0, 4.0, moonVisibility);
  fogDensity = mix(fogDensity, 4.5, rainStrength);

	float dist = length(viewPos) / far;
	float VoU = dot(normalize(viewPos), upVec);

	float borderFogFactor = exp(-fogDensity * (1.0 - dist));
  float atmosFogFactor = smoothstep(100.0, 0.0, worldPos.y) * 8.0;
  atmosFogFactor *= borderFogFactor;

	float horizonFall = fogify(max(VoU + 0.02, 0.0), h_Dens * 0.25);
  
	float totalFogFac = clamp(atmosFogFactor + borderFogFactor, 0.0, 1.0);
	totalFogFac *= horizonFall;

	return totalFogFac;
}