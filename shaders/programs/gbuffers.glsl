#include "/lib/settings.glsl"

#ifdef VSH

attribute vec2 mc_midTexCoord;;
attribute vec3 mc_Entity;

varying vec3 viewPos;
varying vec3 sunVec, upVec;

#if defined(SOLID) || defined(TRANSLUCENT)
  varying vec2 uv0;
  varying vec2 uv1;
  varying vec3 normal;
  varying vec3 alphaTest;
  varying vec4 glColor;
#endif // defined(SOLID) || defined(TRANSLUCENT)
  
#ifdef TRANSLUCENT
  varying float waterMask;
#endif // TRANSLUCENT

#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"

void main() {
  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

  #include "/lib/src/sunvector.glsl"

  #if defined(SOLID) || defined(TRANSLUCENT)
    uv0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    uv1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glColor = gl_Color;

    normal = normalize(gl_NormalMatrix * gl_Normal);

    float NdotL = clamp(dot(normal, sunVec), 0.0, 1.0) * clamp(dot(sunVec, upVec) * 3.0, 0.0, 1.0);

    if (mc_Entity.x == 1.0) {
      alphaTest.x = 1.0;
      if (uv0.y > mc_midTexCoord.y) {
        glColor.rgb *= mix(0.65, 1.5, max(NdotL, uv1.x));
      }
    }

    if (mc_Entity.x == 2.0) {
      alphaTest.y = 1.0;
    }
  #endif // defined(SOLID) || defined(TRANSLUCENT)

  #ifdef TRANSLUCENT
    waterMask = mc_Entity.x == 3.0 ? 1.0 : 0.0;
  #endif // TRANSLUCENT

  gl_Position = ftransform();
}

#endif // VSH

#ifdef FSH

varying vec3 viewPos;
varying vec3 sunVec, upVec;

#if defined(SOLID) || defined(TRANSLUCENT)
  varying vec2 uv0;
  varying vec2 uv1;
  varying vec3 normal;
  varying vec3 alphaTest;
  varying vec4 glColor;
#endif // defined(SOLID) || defined(TRANSLUCENT)

#ifdef TRANSLUCENT
  varying float waterMask;
#endif // TRANSLUCENT

#include "/lib/uniforms.glsl"
#include "/lib/utils.glsl"
#include "/lib/common.glsl"

#ifdef SKYBASIC
  #include "/lib/sky.glsl"
#endif // SKYBASIC

void main() {
  vec4 outColor = vec4(1.0, 1.0, 1.0, 1.0);

  #ifdef SKYBASIC
    vec3 noPos = normalize(viewPos);
    outColor = getSky(noPos);
  #endif // SKYBASIC

  #if defined(SOLID) || defined(TRANSLUCENT)
    #ifdef SKYTEXTURED
      outColor = texture2D(texture, uv0) * glColor * 1.5;
    #else // SKYTEXTURED
      outColor = texture2D(texture, uv0) * glColor;
    #endif // SKYTEXTURED
  #endif // defined(SOLID) || defined(TRANSLUCENT)

  #ifdef TRANSLUCENT
    outColor.a *= waterMask > 0.0 ? 0.0 : 1.0;
  #endif // TRANSLUCENT
  
  // to linear
  outColor.rgb = toLinear(outColor.rgb);

  #ifdef SKYTEXTURED
    float VoU = dot(normalize(viewPos), upVec);
    float horizonFall = fogify(max(VoU + 0.02, 0.0), h_Dens);
    
    // improve sun moon
    outColor.rgb = mix(vec3(luminance(outColor.rgb)), outColor.rgb, 1.5);
    outColor.a *= (1.0 - horizonFall) * (1.0 - rainStrength);
  #endif // SKYTEXTURED

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = outColor;

  #if defined(SOLID) || defined(TRANSLUCENT)
    /* DRAWBUFFERS:0123 */
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
    gl_FragData[2] = vec4(uv1, 0.0, 1.0);
    gl_FragData[3] = vec4(alphaTest, 1.0);
  #endif // defined(SOLID) || defined(TRANSLUCENT)
}

#endif // FSH