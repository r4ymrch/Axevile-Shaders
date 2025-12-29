float timeAngle = float(worldTime) * 4.167e-5;
float sunAngle = fract(timeAngle - 0.25);

sunAngle = sunAngle + (cos(sunAngle * PI) * -0.5 + 0.5 - sunAngle) * 0.333333333;
sunAngle *= TWO_PI;

sunVec = vec3(-sin(sunAngle), cos(sunAngle), 0.0) * 2000.0;

float pathRotation = radians(sunPathRotation);
sunVec.yz *= rotmat(pathRotation);

sunVec = mat3(gbufferModelView) * sunVec;
sunVec = normalize(sunVec);

upVec = normalize(gbufferModelView[1].xyz);