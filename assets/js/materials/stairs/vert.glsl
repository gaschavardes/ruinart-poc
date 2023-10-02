#ifndef HALF_PI
#define HALF_PI 1.5707963267948966
#define PI 3.14159265359
#endif
precision highp float;
precision highp int;
uniform float random;
uniform float uTime;
uniform float uScroll;
uniform float uTransitionProgress;
uniform vec2 ratio;
uniform float id;
uniform float uCount;
varying vec2 vRatio;
varying float vOpacity;
varying float defY;
varying float defX;



#include <dynamicBaseVertPars>

varying vec2 vUv;

float circularIn(float t) {
   return 1.0 - sqrt(1.0 - t * t);
}
float sineOut(float t) {
  return sin(t * HALF_PI);
}
float exponentialOut(float t) {
  return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
}

float exponentialIn(float t) {
  return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

mat4 scaleMatrix(float val)
{

		return mat4(val, 0., 0., 0.,
					0., val, 0., 0.,
					0., 0., val, 0., 
					0., 0., 0., 1.);
}


mat4 rotationMatrix(vec3 axis, float angle)
{
		axis = normalize(axis);
		float s = sin(angle);
		float c = cos(angle);
		float oc = 1.0 - c;

		return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
														oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
														oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
														0.0,                                0.0,                                0.0,                                1.0);
}

 vec3 deformationCurve(vec3 position, vec2 uv, vec2 offset) {
   vec2 way = vec2(
	1. - smoothstep(0., 1., uv.x) * 2.,
	1. - smoothstep(0., 1., uv.y) * 2.
   );
   defY = way.y * (sin(uv.x * PI) * offset.y);
   defX = way.x * (sin(uv.y * PI) * offset.x);
//    position.x = position.x + defX + way.x * -smoothstep(-1., 1., -position.y) * offset.y * 2.;
   position.x = position.x + defX;
   position.y = position.y + defY;
   return position;
 }

void main()	{
	vUv = uv;
	vRatio = ratio;
	// mat4 newInstance = instanceMatrix;
	
	vec4 newPos = vec4(position, 1.);
	// newPos *= rotationMatrix(vec3(0., 0., 1.), sin(uTime * 0.001 + random * 30.) * 0.02);

	float maxScale = 1.;
	float scaleVal = clamp( mod((uScroll - id ), uCount), 0., 1.) * maxScale + mod(uScroll - id, uCount) * 0.2;
	
	// float zVal = clamp(mod(uScroll - id, -400.), 0., 1.) * 2.;
	newPos *= scaleMatrix(scaleVal  * 0.5);
	newPos.rgb = deformationCurve(newPos.rgb, uv, vec2(0.2 * smoothstep(maxScale - 0.5, maxScale + 2., scaleVal)));

	newPos.z -= mod((uScroll - id), uCount) * 0.001;

	vOpacity = smoothstep( maxScale - 0.6, maxScale, clamp( mod((uScroll - id), uCount), 0., 1.) * maxScale) * (smoothstep(maxScale + 1., maxScale + 0.9, scaleVal));
	// vOpacity = 1.;
	// newInstance[3][1] -= exponentialIn(distance(instanceMatrix[3].xz, cameraPosition.xz) * .25 - sineOut(clamp(uTransitionProgress, 0., 1.)) * 0.5 + .5) + sin(uTime * 0.001 + random) * (random + 1.) * 0.002;

	vec3 transformedPosition = newPos.rgb;
	
	#include <dynamicBaseVert>
    
	gl_Position = projectionMatrix * modelViewMatrix * newPos;
	// gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.);

	// Override mvPosition to account for new transformations
	// mvPosition = modelViewMatrix * newInstance * newPos;
	// vViewPosition = - mvPosition.xyz;
    // vWorldPosition = modelMatrix * newInstance * newPos;
}