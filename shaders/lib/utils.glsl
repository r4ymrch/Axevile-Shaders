const float PI = 3.14159265;
const float TWO_PI = 6.28318531;
const float invNoiseRes = 1.0 / 256.0;

float luminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}

vec3 toLinear(vec3 x) {
  return pow(x, vec3(2.2, 2.2, 2.2));
}

vec3 toSRGB(vec3 x) {
  return pow(x, vec3(1.0 / 2.2, 1.0 / 2.2, 1.0 / 2.2));
}

float fogify(float x, float width) {
	return width / (x * x + width);
}

float miePhase(float mu, float g) {
  float mu2 = mu * mu;
	float g2 = g * g;

  float x = 1.0 + g2 - 2 * mu * g;

  float denom = x * sqrt(x) * (2.0 + g2);
  const float k = 0.119366;

  return k * ((1.0 - g2) * (mu2 + 1.0)) / denom;
}

mat2 rotmat(float x) {
  return mat2(cos(x), sin(x), -sin(x), cos(x));
}