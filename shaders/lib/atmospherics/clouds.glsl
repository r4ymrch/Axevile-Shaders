#if cloud_type == 1
  const float cloudMinAltitude = bcloud_altitude;
  const float cloudMaxAltitude = bcloud_altitude + bcloud_density;
  const float cloudDensity = bcloud_density;
  const float cloudDist = cloud_distance;
  const float cloudMieStrength = bcloud_mie_strength;
  const float cloudMieG = bcloud_mie_g;
  const float cloudMieMult = bcloud_mie_mult * 3.0;
#elif cloud_type == 2
  const float cloudMinAltitude = vcloud_altitude;
  const float cloudMaxAltitude = vcloud_altitude + vcloud_density;
  const float cloudDensity = vcloud_density;
  const float cloudDist = cloud_distance + 12.0;  
  const float cloudMieStrength = vcloud_mie_strength;
  const float cloudMieG = vcloud_mie_g;
  const float cloudMieMult = vcloud_mie_mult * 1.5;
#endif

float noise3d(vec3 x) {
	vec3 ip = floor(x);
	vec3 fp = fract(x);
  fp = fp * fp * (3.0 - 2.0 * fp);

  float a = texture2D(noisetex, ((ip.xy + ip.z * vec2(17.0, 37.0)) + fp.xy + 0.5) * invNoiseResolution).r;
  float b = texture2D(noisetex, ((ip.xy + (ip.z + 1.0) * vec2(17.0, 37.0)) + fp.xy + 0.5) * invNoiseResolution).r;

	return mix(a, b, fp.z);
}

float getCloudSample(vec3 position) {
	if (position.y < cloudMinAltitude || position.y > cloudMaxAltitude) {
    return 0.0;
  }
	
  float height = (position.y - cloudMinAltitude) / cloudDensity;
  float heightAttenuation = 0.0;
  float cloudMap = 0.0;
    
  #if cloud_type == 1
    const float heightAttenStart = 0.1;
    const float heightAttenEnd = 0.9;
    
    vec2 cloudPos = position.xz * invNoiseResolution;
    cloudPos.x += cloud_move_speed * frameTimeCounter * 0.05;
    cloudPos = floor(cloudPos) * 3.0;
    cloudPos *= 0.0018;

    cloudMap = step(bcloud_coverage, texture2D(noisetex, cloudPos).g);
      
  #elif cloud_type == 2
    const float heightAttenStart = 0.4;
    const float heightAttenEnd = 0.7;

    vec3 cloudPos = position * 0.001;
      
    float density = 1.0;
    for (int i = 0; i < 4; i++) {
		  cloudMap += noise3d(cloudPos) * density;
      density *= 0.5;
		  cloudPos *= 2.5;
		  cloudPos.xz += cloud_move_speed * frameTimeCounter * 0.05;
    }

    float coverage = texture2D(noisetex, position.xz * 0.00002 + frameTimeCounter * 0.0001).b;
    coverage *= vcloud_coverage;
    
    cloudMap *= coverage;  
  #endif

  heightAttenuation = remap(height, 0.0, heightAttenStart, 0.0, 1.0) * remap(height, heightAttenEnd, 1.0, 1.0, 0.0);
  heightAttenuation = clamp(heightAttenuation, 0.0, 1.0);

  #if cloud_type == 1
    cloudMap *= heightAttenuation - 0.5;
  #elif cloud_type == 2
    cloudMap *= heightAttenuation;
    cloudMap -= heightAttenuation * 0.5 + height * 0.5;
  #endif

  return clamp(cloudMap, 0.0, 1.0) * 0.05;
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
  float rSteps = cloudDensity / cloud_light_steps;

  vec3 increment = sunVector * rSteps;
  vec3 lightPos = increment * 0.5 + position;
	
  float cloud = 0.0;
	for (int i = 0; i < cloud_light_steps; i++, lightPos += increment) {
    cloud += getCloudSample(lightPos);
  }
  cloud *= rSteps;

	float powder = 1.0 - exp(-density * 2.0);
  float phase = phase2Lobes(VoL, cloudMieStrength, cloudMieG) * cloudMieMult;
  phase *= (1.0 - 0.5 * rainStrength);
  
  scatter.x += (1.0 - opticalDepth) * exp(-cloud) * transmittance * powder * phase;
  scatter.y += (1.0 - opticalDepth) * transmittance;
}

vec4 getVolumetricClouds(vec3 rayOrigin, vec3 rayDir, float dither) {
  vec4 totalClouds = vec4(0.0, 0.0, 0.0, 1.0);
  
  float t_min = raySphereIntersect(rayOrigin.y, cloudMinAltitude);
  float t_max = raySphereIntersect(rayOrigin.y, cloudMaxAltitude);

  if (t_min == 0.0 && t_max == 0.0) return totalClouds;

  vec3 startPos = rayOrigin * t_min;
  vec3 endPos = rayOrigin * t_max;

	vec3 increment = (endPos - startPos) / cloud_steps;
	vec3 cloudPos = increment * dither + startPos;
  
  float VoL = dot(rayOrigin, rayDir);
  float stepLength = length(increment);
  
	float transmittance = 1.0;
  vec2 scatter = vec2(0.0);

	for (int i = 0; i < cloud_steps; i++, cloudPos += increment) {
		float density = getCloudSample(cloudPos);
    if (density <= 0.0) continue;

    density *= stepLength;
		
    float opticalDepth = exp(-density);
		
    calculateCloudScattering(
      scatter, 
      cloudPos, 
      rayDir, 
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

	vec3 lightColor = mix(totalFogColor * (1.0 + 1.0 * dayMixer), nightColor * 2.0, nightMixer);
  lightColor = pow(lightColor, vec3(2.2));
	
	vec3 zenithColor = mix(totalSkyColor, nightColor * 0.2, nightMixer) * 0.25;
  
  totalClouds.rgb = scatter.x * lightColor + scatter.y * zenithColor;

  if (rainStrength > 0.0) {
    vec3 rainColor = vec3(luminance(totalClouds.rgb)) * vec3(0.6, 0.8, 1.0) * 0.85;
    totalClouds.rgb = mix(totalClouds.rgb, rainColor, rainStrength);
  }

  totalClouds.a = transmittance;

  float opacity = max(cloud_opacity - 0.85 * rainStrength, 0.1);
  totalClouds = mix(vec4(0.0, 0.0, 0.0, 1.0), totalClouds, opacity);

  float fallOff = clamp(length(cloudPos) / cloudDist * 0.001, 0.0, 1.0);
  totalClouds = mix(totalClouds, vec4(0.0, 0.0, 0.0, 1.0), fallOff);

  return totalClouds;
}