#include "/lib/settings.glsl"

#ifdef VSH

varying vec2 uv0;

void main() {
  uv0 = gl_MultiTexCoord0.xy;
  gl_Position = ftransform();
}

#endif // VSH

#ifdef FSH

varying vec2 uv0;

#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/tonemap.glsl"

void main() {
  vec3 outColor = texture2D(colortex0, uv0).rgb;
  
  outColor = reinhard(outColor);
  outColor = toSRGB(outColor);
  outColor = mix(vec3(luminance(outColor)), outColor, 1.2);
  outColor = pow(outColor, vec3(1.4));

  gl_FragColor = vec4(outColor, 1.0);
}

#endif // FSH