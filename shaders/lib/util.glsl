// const float invNoiseRes = 1.0 / 256.0;
const float invNoiseRes = 1.0 / 512.0;

float luma(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
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

float getLD(float depth) {
  depth = depth * 2.0 - 1.0; 
  vec2 zw = depth * gbufferProjectionInverse[2].zw + gbufferProjectionInverse[3].zw;
  return -zw.x / zw.y;
}

mat2 rotateMatrix(float x) {
  return mat2(cos(x), sin(x), -sin(x), cos(x));
}