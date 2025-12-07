#if cloud_type == 1
  const float cloudMinAltitude = bcloud_altitude;
  const float cloudMaxAltitude = bcloud_altitude + bcloud_density;
#elif cloud_type == 2
  const float cloudMinAltitude = vcloud_altitude;
  const float cloudMaxAltitude = vcloud_altitude + vcloud_density;
#endif // cloud_type

float noise3d(vec3 x) {
	vec3 ip = floor(x);
	vec3 fp = fract(x);
  fp = fp * fp * (3 - 2 * fp);

  float a = texture2D(noisetex, ((ip.xy + ip.z * vec2(17, 37)) + fp.xy + 0.5) * invNoiseResolution).r;
  float b = texture2D(noisetex, ((ip.xy + (ip.z + 1) * vec2(17, 37)) + fp.xy + 0.5) * invNoiseResolution).r;

	return mix(a, b, fp.z);
}

float getCloudSample(vec3 position) {
	if (position.y < cloudMinAltitude || position.y > cloudMaxAltitude) return 0;
	
  float height = 0;
  float heightAttenuation = 0;
  float cloudMap = 0;

  #if cloud_type == 1

    vec2 cloudPos = position.xz * invNoiseResolution;
    cloudPos.x += cloud_move_speed * frameTimeCounter * 0.05;
    cloudPos = floor(cloudPos) * 3;
    cloudPos *= 1.8e-3;

    height = (position.y - cloudMinAltitude) / bcloud_density;
	  heightAttenuation = remap(height, 0, 0.1, 0, 1) * remap(height, 0.9, 1, 1, 0);
    heightAttenuation = clamp(heightAttenuation, 0, 1);

    cloudMap = step(bcloud_coverage, texture2D(noisetex, cloudPos).g);
    cloudMap *= heightAttenuation - 0.5;

  #elif cloud_type == 2

	  vec3 cloudPos = position * 1e-3;
    
    float density = 1;
    for (int i = 0; i < 4; i++) {
		  cloudMap += noise3d(cloudPos) * density;
      density *= 0.5;
		  cloudPos *= 2.5;
		  cloudPos.xz += cloud_move_speed * frameTimeCounter * 0.05;
    }
	
    height = (position.y - cloudMinAltitude) / vcloud_density;
	  heightAttenuation = remap(height, 0, 0.4, 0, 1) * remap(height, 0.7, 1, 1, 0);
    heightAttenuation = clamp(heightAttenuation, 0, 1);

    float coverage = texture2D(noisetex, position.xz * 2e-5 + frameTimeCounter * 1e-4).b;
    coverage = coverage * vcloud_coverage;

    cloudMap = cloudMap * heightAttenuation * coverage;
    cloudMap -= heightAttenuation * 0.5 + height * 0.5;

  #endif // cloud_type

  return clamp(cloudMap, 0, 1) * 0.05;
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
  #if cloud_type == 1
    float rSteps = bcloud_density / cloud_light_steps;
  #elif cloud_type == 2
    float rSteps = vcloud_density / cloud_light_steps;
  #endif // cloud_type

  vec3 increment = sunVector * rSteps;
  vec3 lightPos = increment * 0.5 + position;
	
  float cloud = 0;
	for (int i = 0; i < cloud_light_steps; i++, lightPos += increment) {
    cloud += getCloudSample(lightPos) * rSteps;
  }

	float phase = 0;
  float powder = 1 - exp(-density * 2);

  #if cloud_type == 1
    phase = phase2Lobes(VoL, bcloud_mie_strength, bcloud_mie_g) * bcloud_mie_mult * 3;
  #elif cloud_type == 2
    phase = phase2Lobes(VoL, vcloud_mie_strength, vcloud_mie_g) * vcloud_mie_mult * 1.5;
  #endif // cloud_type
  phase = phase * (1 - 0.5 * rainStrength);
  
  scatter.x += (1 - opticalDepth) * exp(-cloud) * transmittance * powder * phase;
  scatter.y += (1 - opticalDepth) * transmittance;
}

vec4 getVolumetricClouds(vec3 position, vec3 sunVector, float dither) {
  vec4 totalClouds = vec4(0, 0, 0, 1);
  
  vec3 startPos = position * raySphereIntersect(position.y, cloudMinAltitude);
  vec3 endPos = position * raySphereIntersect(position.y, cloudMaxAltitude);

	vec3 increment = (endPos - startPos) / cloud_steps;
	vec3 cloudPos = increment * dither + startPos;
  
  float VoL = dot(position, sunVector);
  float stepLength = length(increment);
  
	float transmittance = 1;
  float opticalDepth = 0;
	
  vec2 scatter = vec2(0);
	for (int i = 0; i < cloud_steps; i++, cloudPos += increment) {
		float density = getCloudSample(cloudPos) * stepLength;
    if(density <= 0) continue;
		
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

  totalClouds.rgb = scatter.x * lightColor;
  totalClouds.rgb += scatter.y * zenithColor;

  if (rainStrength > 0) {
	  vec3 rainColor = vec3(luminance(totalClouds.rgb)) * vec3(0.6, 0.8, 1) * 0.85;
    totalClouds.rgb = mix(totalClouds.rgb, rainColor, rainStrength);
  }

  totalClouds.a = transmittance;

  float opacity = max(cloud_opacity - 0.85 * rainStrength, 0.1);
  totalClouds = mix(vec4(0, 0, 0, 1), totalClouds, opacity);

  #if cloud_type == 1
    float furthest = cloud_distance;
  #elif cloud_type == 2
    float furthest = cloud_distance + 12;
  #endif // cloud_type

  float fallOff = clamp(length(cloudPos) / furthest * 1e-3, 0, 1);
  totalClouds = mix(totalClouds, vec4(0, 0, 0, 1), fallOff);

  return totalClouds;
}