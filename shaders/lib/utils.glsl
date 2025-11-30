/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RGB8;
const int colortex2Format = RG8;
*/

float luminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}

float fogify(float x, float width) {
	return width / (x * x + width);
}

float miePhase(float mu, float g) {
  float mu2 = mu * mu;
	float g2 = g * g;
  float x = 1 + g2 - 2 * mu * g;

  float denom = x * sqrt(x) * (2 + g2);
  const float k = 0.119366;
  
  return k * ((1 - g2) * (mu2 + 1)) / denom;
}

vec3 projectAndDivide(mat4 matrix, vec3 vectors) {
  vec4 homoPos = matrix * vec4(vectors, 1);
  return homoPos.xyz / homoPos.w;
}

vec3 cameraSpaceToViewSpace(vec2 cameraPos, float depth) {
  vec4 fragPos = vec4(cameraPos, depth, 1) * 2 - 1;
  return projectAndDivide(gbufferProjectionInverse, fragPos.xyz);
}

vec3 viewSpaceToWorldSpace(vec3 viewPos) {
	return mat3(gbufferModelViewInverse) * viewPos + gbufferModelViewInverse[3].xyz;
}

mat2 rotateMatrix(float x) {
  return mat2(cos(x), sin(x), -sin(x), cos(x));
}
