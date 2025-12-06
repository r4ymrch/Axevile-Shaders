const float cloudMinAltitude = cloud_altitude;
const float cloudMaxAltitude = cloud_altitude + cloud_density;

float getCloudSample(vec3 position) {
	if (position.y < cloudMinAltitude || position.y > cloudMaxAltitude) return 0.0;
	
  float height = (position.y - cloudMinAltitude) / cloud_density;
	float heightAttenuation = remap(height, 0, 0.1, 0, 1) * remap(height, 0.9, 1, 1, 0);
  heightAttenuation = clamp(heightAttenuation, 0, 1);
	
  vec2 cloudPos = position.xz * invNoiseResolution * 3;
  cloudPos *= 1.8e-3;
  cloudPos += vec2(frameTimeCounter * 3e-4, 0);

  float cloudMap = texture2D(noisetex, fract(cloudPos)).r;
	
  return clamp(cloudMap * heightAttenuation - 0.5, 0, 1) * 0.05;
}

void calculateCloudScattering(
  inout vec2 scatter, 
  in vec3 position, 
  in vec3 sunVector, 
  in float density, 
  in float VoL, 
  in float opticalDepth, 
  in float transmittance
) {
	float rSteps = cloud_density / cloud_light_steps;

  vec3 increment = sunVector * rSteps;
  vec3 lightPos = increment * 0.5 + position;
	
  float cloud = 0.0;
	for (int i = 0; i < cloud_light_steps; i++, lightPos += increment) {
    cloud += getCloudSample(lightPos) * rSteps;
  }

	float phase = phase2Lobes(VoL) * (1 - 0.5 * rainStrength);
  float powder = 1 - exp(-density * 2);

  scatter.x += (1 - opticalDepth) * exp(-cloud) * transmittance * powder * phase;
  scatter.y += (1 - opticalDepth) * transmittance;
}

vec4 getVolumetricClouds(vec3 position, vec3 sunVector, float dither) {
  vec3 startPos = position * raySphereIntersect(position.y, cloudMinAltitude);
  vec3 endPos = position * raySphereIntersect(position.y, cloudMaxAltitude);

	vec3 increment = (endPos - startPos) / cloud_quality;
	vec3 cloudPos = increment * dither + startPos;
  
  float VoL = dot(position, sunVector);
  float stepLength = length(increment);
  
	float transmittance = 1.0;
  float opticalDepth = 0.0;
	
  vec2 scatter = vec2(0);
	for (int i = 0; i < cloud_quality; i++, cloudPos += increment) {
		float density = getCloudSample(cloudPos) * stepLength;
    if(density <= 0.0) continue;
		
    float opticalDepth = exp(-density);
		
    calculateCloudScattering(
      scatter, 
      cloudPos, 
      sunVector, 
      density, 
      VoL, 
      opticalDepth, 
      transmittance
    );
    
    transmittance *= opticalDepth;
  }

  vec3 totalSkyColor = skyColor * (0.5 + 0.5 * dayMixer);
  vec3 totalFogColor = fogColor * (vec3(1.65, 0.85, 0.4) + vec3(-0.65, 0.15, 0.6) * dayMixer);
  vec3 nightColor = skyColor * vec3(0.8, 0.65, 0.5);

	vec3 sunColor = totalFogColor * (1 + 1 * dayMixer);
	vec3 moonColor = nightColor * 2;
  vec3 lightColor = mix(sunColor, moonColor, nightMixer);
  lightColor = pow(lightColor, vec3(2.2));
	
  vec3 zenithColor = totalSkyColor;
	zenithColor = mix(zenithColor, nightColor * 0.2, nightMixer) * 0.25;

  vec4 totalClouds = vec4(0);
  totalClouds.rgb = scatter.x * lightColor;
  totalClouds.rgb += scatter.y * zenithColor;

  if (rainStrength > 0) {
	  vec3 rainColor = vec3(luminance(totalClouds.rgb)) * vec3(0.6, 0.8, 1) * 0.85;
    totalClouds.rgb = mix(totalClouds.rgb, rainColor, rainStrength);
  }

  totalClouds.a = transmittance;

  float opacity = max(cloud_opacity - 0.85 * rainStrength, 0.1);
  totalClouds = mix(vec4(0, 0, 0, 1), totalClouds, opacity);

  float fallOff = clamp(length(cloudPos) / cloud_distance * 1e-3, 0, 1);

  return mix(totalClouds, vec4(0, 0, 0, 1), fallOff);
}