/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RGB8;
const int colortex2Format = RG8;
*/

const float invNoiseResolution = 0.00390625;

float luminance(vec3 x) {
  return dot(x, vec3(0.2125, 0.7154, 0.0721));
}

float fogify(float x, float width) {
	return width / (x * x + width);
}

float remap(float value, float min1, float max1, float min2, float max2) { 
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1); 
}

float raySphereIntersect(float y, float h) {
	float radius = 6371e3 + h;
  float radiusSquared = radius * radius;
  
  float ds = y * 6371e3;
  float dsSquared = ds * ds;
	
  return -ds + sqrt(dsSquared + radiusSquared - 4.058964e13);
}

float miePhase(float mu, float g) {
  float mu2 = mu * mu;
	float g2 = g * g;
  float x = 1 + g2 - 2 * mu * g;

  float denom = x * sqrt(x) * (2 + g2);
  const float k = 0.119366;
  
  return k * ((1 - g2) * (mu2 + 1)) / denom;
}

float phase2Lobes(float x, float m, float mg) {
  float lobe1 = miePhase(x, mg);
  float lobe2 = miePhase(x, -0.05);
	
  return mix(lobe2, lobe1, m);
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
