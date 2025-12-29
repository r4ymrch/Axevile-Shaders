float sunVisibility = clamp(dot(sunVec, upVec) * 2.0, 0.0, 1.0);
float moonVisibility = clamp(dot(-sunVec, upVec) * 8.0, 0.0, 1.0);

float h_Dens = HORIZON_DENSITIES * (1.0 - 0.5 * sunVisibility) * 0.0008;
float h_Offset = HORIZON_OFFSET * (0.1 + 0.2 * sunVisibility);

vec3 skyCol = vec3(SKY_COLOR_R, SKY_COLOR_G, SKY_COLOR_B) * 0.00392156863;
vec3 fogCol = vec3(HORIZON_COLOR_R, HORIZON_COLOR_G, HORIZON_COLOR_B) * 0.00392156863;

vec3 zenithCol = skyCol * (0.5 + 0.5 * sunVisibility);
vec3 sunLightCol = fogCol * (vec3(1.2, 0.85, 0.4) + vec3(-0.2, 0.15, 0.6) * sunVisibility);
vec3 moonCol = skyCol * vec3(0.8, 0.65, 0.5);