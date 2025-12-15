vec3 distortShadow(vec3 position) {
	float centerDist = sqrt(dot(position.xy, position.xy));
  float distortFactor = centerDist * 0.9 + (1 - 0.9);

  position.xy /= distortFactor;
  position.z *= 0.2;

	return position;
}