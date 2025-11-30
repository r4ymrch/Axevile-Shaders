float drawCircle(vec3 viewPos, vec3 sunVector, float smoothness, float scale) {
  float distToSun = distance(viewPos, sunVector);
  
  float scaleFactor = scale * 0.1;
  float smoothFactor = scaleFactor - smoothness * 0.1;
  
  return smoothstep(scaleFactor, smoothFactor, distToSun);
}

vec4 calculateSkyScattering(vec3 viewPos) {
  float viewDotUp = dot(viewPos, upVector);
  float viewDotSun = dot(viewPos, sunVector);
  float viewDotMoon = dot(viewPos, -sunVector);

	float zenith = fogify(max(viewDotUp, 0), zenith_density * 1e-2);
  // horizon y offset
  float horizonOffset = horizon_offset * 0.1 + 0.1 * dayMixer;
	float horizonGradient = fogify(max(viewDotUp + horizonOffset, 0), horizon_density * 1e-3);
  
  // change colors according to the sun by multiplying each components with fixed value
  vec3 totalSkyColor = skyColor * (0.5 + 0.5 * dayMixer);
  vec3 totalFogColor = fogColor * (vec3(1.65, 0.85, 0.4) + vec3(-0.65, 0.15, 0.6) * dayMixer);
  vec3 nightColor = skyColor * vec3(0.8, 0.65, 0.5);

  // make sure the value greater than 0 and less than 3 to avoid strange colors
  totalSkyColor = clamp(totalSkyColor, vec3(0), vec3(3));
  totalFogColor = clamp(totalFogColor, vec3(0), vec3(3));
  nightColor  = clamp(nightColor, vec3(0), vec3(3));

  // calculate day sky
  vec3 zenithColorDay = vec3(0) + totalSkyColor * zenith;
  vec3 daySky = mix(zenithColorDay, totalFogColor, horizonGradient);

  // calculate night sky
  vec3 zenithColorNight = vec3(0) + nightColor * zenith;
  vec3 nightSky = mix(zenithColorNight, nightColor * 1.5, horizonGradient) * 0.8;

  // functions to mixing day and night sky dynamicly
  // calculate distance to sun
  float distToSun = distance(viewPos, sunVector);
  float skyMixer = smoothstep(1, 0.35, distToSun * 0.5) + exp(-distToSun * 0.2) * dayMixer;
  // night exception
  skyMixer *= (1 - nightMixer);
  
  vec3 finalSky = mix(nightSky, daySky, skyMixer);

  float starAlpha = 0;
  #ifdef STARS
    // stars fade out when hitting the sky horizon
    float starFallOff = max(skyMixer, horizonGradient);
    starAlpha = stars_brightness * (1 - starFallOff) * (1 - dayMixer);
    // prevent the stars become black in some conditions
    starAlpha = clamp(starAlpha, 0, 1);
  #endif // STARS

  // TODO : hide sun and moon under the horizon
  #ifdef ROUNDED_SUNMOON
    float sunShape = drawCircle(viewPos, sunVector, 0.25, 0.55);

    // crescent moon shape
    // TODO : dynamic moon phase
    float moonShape = drawCircle(viewPos, -sunVector, 0.1, 0.5);
    moonShape *= 1 - drawCircle(viewPos - vec3(0.01, 0.01, 0), -sunVector, 0.2, 0.56);
    
    vec3 sun = totalFogColor * 3 * sunShape;
    vec3 moon = nightColor * 3 * moonShape;

    finalSky += sun + moon;
  #endif // ROUNDED_SUNMOON

  // TODO : sky ground

  // mie phase constants
  const float outerG = mie_phase_g;
  const float innerG = 0.925;
  
  // use multiple mie to achieve more realistic light
  float phaseSun = miePhase(viewDotSun, outerG) * 0.05;
  phaseSun += miePhase(viewDotSun, innerG) * 0.025;
  
  float phaseMoon = miePhase(viewDotMoon, outerG) * 0.35;
  phaseMoon += miePhase(viewDotMoon, innerG) * 0.035;
  
  vec3 mieScatterMoon = nightColor * phaseMoon * nightMixer;
  vec3 mieScatterSun = totalFogColor * phaseSun;
  // night exception
  mieScatterSun *= (1 - nightMixer);

  float adjustedMieStrength = 2 - 1 * nightMixer;
  adjustedMieStrength *= mie_strength_mult;

  vec3 totalMieScattering = adjustedMieStrength * (mieScatterSun + mieScatterMoon);
  
  // rain exception
  totalMieScattering *= (1 - rainStrength);
  
  finalSky += totalMieScattering;

  // sky when camera in water
  if (isEyeInWater == 1) {
    // TODO : fancy sky underwater
    finalSky = mix(totalSkyColor, nightColor * 0.5, nightMixer); // simple
  }

  // sky during rain
  if (rainStrength > 0) {
	  vec3 rainColor = vec3(luminance(finalSky)) * vec3(0.6, 0.8, 1) * 0.85;
    finalSky = mix(finalSky, rainColor, rainStrength);
  }

  return vec4(sky_brightness * finalSky, starAlpha);
}
