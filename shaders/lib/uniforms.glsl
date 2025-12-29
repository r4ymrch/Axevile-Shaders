/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RGB8;
const int colortex2Format = RG8;
const int colortex3Format = RGB8;
*/

uniform sampler2D noisetex;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;

uniform sampler2D depthtex0;

uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowcolor0;

#if defined(SOLID) ||defined(TRANSLUCENT)
  uniform sampler2D texture;
#endif // defined(SOLID) ||defined(TRANSLUCENT)

uniform int worldTime;
uniform int isEyeInWater;

uniform float far;
uniform float near;
uniform float rainStrength;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;

const bool shadowHardwareFiltering = true;
const int shadowMapResolution = 1536;
const float sunPathRotation = -40.0;
const float ambientOcclusionLevel = 0.7;
const float shadowDistance = 128.0;