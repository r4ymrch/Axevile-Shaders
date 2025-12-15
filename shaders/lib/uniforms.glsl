uniform sampler2D noisetex;
uniform sampler2D colortex0;
uniform sampler2D colortex1; // normal
uniform sampler2D colortex2; // lightmap
uniform sampler2D colortex3; // alphatest
uniform sampler2D colortex4; // ao
uniform sampler2D depthtex0;

uniform sampler2D shadowcolor0;
uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;

uniform int isEyeInWater;

uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float timeAngle;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;