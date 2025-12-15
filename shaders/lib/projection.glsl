vec3 projAndDiv(mat4 m, vec3 v) {
  vec4 homoPos = m * vec4(v, 1.0);
  return homoPos.xyz / homoPos.w;
}

vec3 toView(vec2 pos, float depth) {
  vec4 fragPos = vec4(pos, depth, 1.0) * 2.0 - 1.0;
  return projAndDiv(gbufferProjectionInverse, fragPos.xyz);
}

vec3 toWorld(vec3 pos) {
	return mat3(gbufferModelViewInverse) * pos + gbufferModelViewInverse[3].xyz;
}

vec3 toShadow(vec3 pos) {
	vec3 fragPos = mat3(shadowModelView) * pos + shadowModelView[3].xyz;
	
  vec3 diagonal3 = vec3(
    shadowProjection[0].x, 
    shadowProjection[1].y, 
    shadowProjection[2].z
  );
  
  return diagonal3 * fragPos + shadowProjection[3].xyz;
}