uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex9;

uniform int isEyeInWater;

uniform float far;
uniform float near;
uniform float frameTimeCounter;
uniform float aspectRatio;
uniform float viewWidth;
uniform float viewHeight;
uniform float timeAngle;
uniform float rainStrength;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;