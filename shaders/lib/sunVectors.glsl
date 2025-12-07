
void calculateSunVector(
  inout vec3 sunVector, 
  inout vec3 lightVector, 
  inout vec3 upVector
) {
  float sunAngle = fract(timeAngle - 0.25);
  sunAngle = (sunAngle + (cos(sunAngle * 3.14) * -0.5 + 0.5 - sunAngle) / 3.0) * 6.28;

  sunVector = vec3(-sin(sunAngle), cos(sunAngle), 0.0) * 2000.0;
  
  float pathRotation = radians(sunPathRotation);
  sunVector.yz *= rotateMatrix(pathRotation);

  sunVector = projectAndDivide(gbufferModelView, sunVector);
  sunVector = normalize(sunVector);

  lightVector = (timeAngle < 0.5325 || timeAngle > 0.9675) ? sunVector : -sunVector;
  upVector = normalize(gbufferModelView[1].xyz);
}