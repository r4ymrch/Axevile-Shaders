vec3 Tonemap(vec3 x) {
	return x / (0.9813 * x + 0.1511);
}