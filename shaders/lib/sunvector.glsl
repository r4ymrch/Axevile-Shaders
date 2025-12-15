const float PI = 3.14;
const float TWO_PI = 6.28;

float sunAngle = fract(timeAngle - 0.25);
sunAngle = (sunAngle + (cos(sunAngle * PI) * -0.5 + 0.5 - sunAngle) / 3.0) * TWO_PI;

sunVec = vec3(-sin(sunAngle), cos(sunAngle), 0.0) * 2000.0;

float pathRotation = radians(sunPathRotation);
float cosX = cos(pathRotation);
float sinX = sin(pathRotation);

mat2 rotateMatrix = mat2(cosX, sinX, -sinX, cosX);
sunVec.yz *= rotateMatrix;

sunVec = mat3(gbufferModelView) * sunVec;
sunVec = normalize(sunVec);

// lightVector = (timeAngle < 0.5325 || timeAngle > 0.9675) ? sunVector : -sunVector;
upVec = normalize(gbufferModelView[1].xyz);