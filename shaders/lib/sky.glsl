float getSunMoonShape(vec3 viewPos, vec3 sunVec, float edgeSmooth, float scale) {
  float dist = distance(viewPos, sunVec);
  float scaleFactor = scale * 0.1;
  float smoothFactor = scaleFactor - edgeSmooth * 0.1;
  
  return smoothstep(scaleFactor, smoothFactor, dist);
}

vec4 getSky(vec3 viewPos) {
  float VoU = dot(viewPos, upVec);
  float VoL_Sun = dot(viewPos, sunVec);
  float VoL_Moon = dot(viewPos, -sunVec);

	float zenith = fogify(max(VoU, 0.0), ZENITH_DENSITIES * 0.01);
  vec3 zenithSun = vec3(0.0) + zenithCol * zenith;
  vec3 zenithMoon = vec3(0.0) + moonCol * 0.7 * zenith;
  
	float horizonBase = fogify(max(VoU + h_Offset, 0.0), h_Dens + 0.025);
	float horizonFall = fogify(max(VoU + 0.02, 0.0), h_Dens);
	float horizonFall2 = fogify(max(VoU + 0.02, 0.0), h_Dens * 0.075);
  float horizonExit = fogify(max(VoU + 1.0, 0.0), 1.0) * horizonFall * 0.7;

  vec3 sunSky = mix(zenithSun, sunLightCol * (1.5 - 0.5 * sunVisibility), horizonBase);
  
  vec3 skyFade = mix(sunSky, sunLightCol * 0.6, horizonFall);
  vec3 skyGround = mix(sunSky, pow(zenithCol, vec3(0.5)) * 0.7, horizonFall2);
  skyGround = mix(skyGround, sunLightCol * 0.6, horizonFall * rainStrength);
  
  skyGround = mix(skyGround, sunLightCol * 0.1, horizonExit);
  skyGround = pow(skyGround, vec3(1.3)) * 1.4;

  sunSky = mix(skyFade, skyGround, clamp(0.25 + 0.75 * sunVisibility, 0.0, 1.0));

  vec3 moonSky = mix(zenithMoon, moonCol * 1.5, horizonBase) * 0.75;
  moonSky = mix(moonSky, moonCol * 0.5, horizonFall2);

  // functions to mixing day and night sky dynamicly
  float dist = distance(viewPos, sunVec);
  float skyMixFactor = smoothstep(1.0, 0.0, dist * 0.4) + 1.0 * sunVisibility;
  skyMixFactor *= 1.0 - moonVisibility;
  
  vec4 sky = vec4(0.0);
  sky.rgb = mix(moonSky, sunSky, skyMixFactor);

  if (isEyeInWater == 1) {
    // TODO : fancy sky underwater
    sky.rgb = mix(zenithCol, moonCol * 0.5, moonVisibility); // simple
  }

  #ifdef STARS
    float starFallOff = max(skyMixFactor, horizonBase);
    sky.a = STARS_BRIGHTNESS * (1.0 - starFallOff) * (1.0 - sunVisibility);
    sky.a = clamp(sky.a, 0.0, STARS_BRIGHTNESS);
  #endif // STARS

  vec3 sun = sunLightCol * 3.0;
  sun *= getSunMoonShape(viewPos, sunVec, 0.2, 0.4) * 3.0;
  sun *= (1.0 - rainStrength) * (1.0 - horizonFall);

  sky.rgb += sun;

  const float outer_G = MIE_PHASE_G;
  const float inner_G = 0.925;
  
  float mieStrength = MIE_STRENGTH * (2.0 - 1.0 * moonVisibility);
  
  float phaseSun = miePhase(VoL_Sun, outer_G) * 0.2;
  phaseSun += miePhase(VoL_Sun, inner_G) * 0.06;
  
  float phaseMoon = miePhase(VoL_Moon, outer_G) * 0.25;
  phaseMoon += miePhase(VoL_Moon, inner_G) * 0.035;
  
  vec3 mieSun = sunLightCol * vec3(1.5, 1.3, 0.75) * phaseSun * (1.0 - moonVisibility);
  vec3 mieMoon = moonCol * phaseMoon * moonVisibility;

  vec3 mie = (mieSun + mieMoon) * mieStrength;
  mie *= (1.0 - rainStrength);
  
  sky.rgb += mie;

  vec3 lumaSky = vec3(luma(sky.rgb));

  if (rainStrength > 0) {
	  vec3 rainCol = lumaSky * vec3(0.6, 0.8, 1) * 1.25;
    sky.rgb = mix(sky.rgb, rainCol, rainStrength);
  }

  return sky;
}

vec4 getSkyFog(vec3 viewPos) {
  float VoU = dot(viewPos, upVec);
  float VoL_Sun = dot(viewPos, sunVec);
  float VoL_Moon = dot(viewPos, -sunVec);

	float zenith = fogify(max(VoU, 0.0), ZENITH_DENSITIES * 0.01);
  vec3 zenithSun = vec3(0.0) + zenithCol * zenith;
  vec3 zenithMoon = vec3(0.0) + moonCol * 0.7 * zenith;
  
	float horizonBase = fogify(max(VoU + h_Offset, 0.0), h_Dens);
	float horizonFall = fogify(max(VoU + 0.02, 0.0), h_Dens);
	float horizonFall2 = fogify(max(VoU + 0.02, 0.0), h_Dens * 0.5);
  float horizonExit = fogify(max(VoU + 1.0, 0.0), 1.0) * horizonFall * 0.7;

  vec3 sunSky = mix(zenithSun, sunLightCol * (1.5 - 0.5 * sunVisibility), horizonBase);
  
  vec3 skyFade = mix(sunSky, sunLightCol * 0.6, horizonFall);
  vec3 skyGround = mix(sunSky, pow(zenithCol, vec3(0.5)) * 0.7, horizonFall2);
  skyGround = mix(skyGround, sunLightCol * 0.6, horizonFall * rainStrength);

  skyGround = mix(skyGround, sunLightCol * 0.1, horizonExit);
  skyGround = pow(skyGround, vec3(1.3)) * 1.4;

  sunSky = mix(skyFade, skyGround, clamp(0.25 + 0.75 * sunVisibility, 0.0, 1.0));

  vec3 moonSky = mix(zenithMoon, moonCol * 1.5, horizonBase) * 0.75;
  moonSky = mix(moonSky, moonCol * 0.5, horizonFall);

  // functions to mixing day and night sky dynamicly
  float dist = distance(viewPos, sunVec);
  float skyMixFactor = smoothstep(1.0, 0.0, dist * 0.4) + 1.0 * sunVisibility;
  skyMixFactor *= 1.0 - moonVisibility;
  
  vec4 sky = vec4(0.0);
  sky.rgb = mix(moonSky, sunSky, skyMixFactor);

  if (isEyeInWater == 1) {
    // TODO : fancy sky underwater
    sky.rgb = mix(zenithCol, moonCol * 0.5, moonVisibility); // simple
  }

  const float outer_G = MIE_PHASE_G;
  const float inner_G = 0.925;
  
  float mieStrength = MIE_STRENGTH * (2.0 - 1.0 * moonVisibility);
  
  float phaseSun = miePhase(VoL_Sun, outer_G) * 0.2;
  float phaseMoon = miePhase(VoL_Moon, outer_G) * 0.25;
  
  vec3 mieSun = sunLightCol * vec3(1.5, 1.3, 0.75) * phaseSun * (1.0 - moonVisibility);
  vec3 mieMoon = moonCol * phaseMoon * moonVisibility;

  vec3 mie = (mieSun + mieMoon) * mieStrength;
  mie *= (1.0 - rainStrength);
  
  sky.rgb += mie;

  vec3 lumaSky = vec3(luma(sky.rgb));

  if (rainStrength > 0) {
	  vec3 rainCol = lumaSky * vec3(0.6, 0.8, 1) * 1.25;
    sky.rgb = mix(sky.rgb, rainCol, rainStrength);
  }

  return sky;
}
