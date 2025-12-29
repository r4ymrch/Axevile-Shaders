vec4 getSky(vec3 viewPos) {
  float VoU = dot(viewPos, upVec);
  float VoL_Sun = dot(viewPos, sunVec);
  float VoL_Moon = dot(viewPos, -sunVec);

	float zenith = fogify(max(VoU, 0.0), ZENITH_DENSITIES * 0.01);
  vec3 zenithSun = vec3(0.0) + zenithCol * zenith;
  vec3 zenithMoon = vec3(0.0) + moonCol * 0.7 * zenith;

  vec4 horizon = vec4(
    fogify(max(VoU + h_Offset, 0.0), h_Dens + 0.025), // base
    fogify(max(VoU + 0.02, 0.0), h_Dens), // fall
    fogify(max(VoU + 0.02, 0.0), h_Dens * 0.075), // fall2
    fogify(max(VoU + 1.0, 0.0), 1.0) * fogify(max(VoU + 0.02, 0.0), h_Dens) * 0.7 // exit
  );

  vec3 sunSky = mix(zenithSun, sunLightCol * (1.5 - 0.5 * sunVisibility), horizon.x);
  vec3 skyFade = mix(sunSky, sunLightCol * 0.6, horizon.y);
  
  vec3 skyGround = mix(sunSky, pow(zenithCol, vec3(0.5)) * 0.7, horizon.z);
  skyGround = mix(skyGround, sunLightCol * 0.6, horizon.y * rainStrength);  
  skyGround = mix(skyGround, sunLightCol * 0.1, horizon.w);

  sunSky = mix(skyFade, skyGround * 1.4, clamp(0.25 + 0.75 * sunVisibility, 0.0, 1.0));

  vec3 moonSky = mix(zenithMoon, moonCol * 1.5, horizon.x) * 0.75;
  moonSky = mix(moonSky, moonCol * 0.5, horizon.z);

  // functions to mixing day and night sky dynamicly
  float mixFactor = smoothstep(1.0, 0.25, distance(viewPos, sunVec) * 0.5) + 1.0 * sunVisibility;
  mixFactor *= 1.0 - moonVisibility;
  
  vec4 sky = vec4(0.0);
  sky.rgb = mix(moonSky, sunSky, mixFactor);

  #ifdef STARS
    float starFallOff = max(mixFactor, horizon.x);
    sky.a = STARS_BRIGHTNESS * (1.0 - starFallOff) * (1.0 - sunVisibility);
    sky.a = clamp(sky.a, 0.0, STARS_BRIGHTNESS);
  #endif // STARS

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

  if (isEyeInWater == 1) {
    // TODO : fancy sky underwater
    vec3 waterFogColor = vec3(0.2, 0.8, 1.0) * mix(0.15, 0.25, sunVisibility);
    sky.rgb = waterFogColor; // simple
  }

  vec3 lumaSky = vec3(luminance(sky.rgb));

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

  vec4 horizon = vec4(
    fogify(max(VoU + h_Offset, 0.0), h_Dens), // base
    fogify(max(VoU + 0.02, 0.0), h_Dens), // fall
    fogify(max(VoU + 0.02, 0.0), h_Dens * 0.5), // fall2
    fogify(max(VoU + 1.0, 0.0), 1.0) * fogify(max(VoU + 0.02, 0.0), h_Dens) * 0.7 // exit
  );

  vec3 sunSky = mix(zenithSun, sunLightCol * (1.5 - 0.5 * sunVisibility), horizon.x);
  vec3 skyFade = mix(sunSky, sunLightCol * 0.6, horizon.y);
  
  vec3 skyGround = mix(sunSky, pow(zenithCol, vec3(0.5)) * 0.7, horizon.z);
  skyGround = mix(skyGround, sunLightCol * 0.6, horizon.y * rainStrength);  
  skyGround = mix(skyGround, sunLightCol * 0.1, horizon.w);

  sunSky = mix(skyFade, skyGround * 1.4, clamp(0.25 + 0.75 * sunVisibility, 0.0, 1.0));

  vec3 moonSky = mix(zenithMoon, moonCol * 1.5, horizon.x) * 0.75;
  moonSky = mix(moonSky, moonCol * 0.5, horizon.z);

  // functions to mixing day and night sky dynamicly
  float mixFactor = smoothstep(1.0, 0.25, distance(viewPos, sunVec) * 0.5) + 1.0 * sunVisibility;
  mixFactor *= 1.0 - moonVisibility;
  
  vec4 sky = vec4(0.0);
  sky.rgb = mix(moonSky, sunSky, mixFactor);

  #ifdef STARS
    float starFallOff = max(mixFactor, horizon.x);
    sky.a = STARS_BRIGHTNESS * (1.0 - starFallOff) * (1.0 - sunVisibility);
    sky.a = clamp(sky.a, 0.0, STARS_BRIGHTNESS);
  #endif // STARS

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

  if (isEyeInWater == 1) {
    // TODO : fancy sky underwater
    vec3 waterFogColor = vec3(0.2, 0.8, 1.0) * mix(0.15, 0.25, sunVisibility);
    sky.rgb = waterFogColor; // simple
  }

  vec3 lumaSky = vec3(luminance(sky.rgb));

  if (rainStrength > 0) {
	  vec3 rainCol = lumaSky * vec3(0.6, 0.8, 1) * 1.25;
    sky.rgb = mix(sky.rgb, rainCol, rainStrength);
  }

  return sky;
}