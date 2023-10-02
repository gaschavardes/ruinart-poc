#define PI 3.1415926538
#include <dynamicBaseVertPars>
varying vec3 eyeVector;
varying vec3 worldNormal;
varying vec3 newWorldNormal;
varying vec3 worldPosition;
varying vec2 vUv;
varying vec3 initNormal;
attribute float index;
attribute vec3 center;
attribute vec3 random;
attribute float progress;
attribute float letter;
attribute vec3 letterCenter;
uniform float uProgress;
uniform float uStartingTime;
uniform float uTime;
uniform vec2 resolution;
uniform float uAppear;
uniform vec2 uMouse;
varying vec3 vReflect;
varying float vBackface;
varying float zVal;

float easeInQuart(float x) {
return x * x * x * x;
}

float easeInBack(float x) {
float c1 = 1.70158;
float c3 = c1 + 1.;

return c3 * x * x * x - c1 * x * x;
}

float appearProgress(float x) {
	return clamp(x - (letter - letter * 0.9), 0., 1.);
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

vec3 scale(vec3 v, float val) {
	mat4 scaleMat =mat4( val,   0.0,  0.0,  0.0,
																						0.0,  val,   0.0,  0.0,
																						0.0,  0.0,  val,   0.0,
																						0.0,  0.0,  0.0,  1.0
														);
	return (scaleMat * vec4(v, 1.0)).xyz;
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
  mat4 m = rotationMatrix(axis, angle);
  return (m * vec4(v, 1.0)).xyz;
}

vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
    return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}

// NOISE 
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 permute(vec4 x) {
    return mod289(((x*34.0)+1.0)*x);
}
vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}
vec3 fade(vec3 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float n11(float p) {
    return fract(97531.2468 * sin(24680.135 * p));
}
float pnoise(vec3 P, vec3 rep) {
    vec3 Pi0 = mod(floor(P), rep);
    vec3 Pi1 = mod(Pi0 + vec3(1.0), rep);
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P);
    vec3 Pf1 = Pf0 - vec3(1.0);
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;
    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);
    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    vec3 g000 = vec3(gx0.x, gy0.x, gz0.x);
    vec3 g100 = vec3(gx0.y, gy0.y, gz0.y);
    vec3 g010 = vec3(gx0.z, gy0.z, gz0.z);
    vec3 g110 = vec3(gx0.w, gy0.w, gz0.w);
    vec3 g001 = vec3(gx1.x, gy1.x, gz1.x);
    vec3 g101 = vec3(gx1.y, gy1.y, gz1.y);
    vec3 g011 = vec3(gx1.z, gy1.z, gz1.z);
    vec3 g111 = vec3(gx1.w, gy1.w, gz1.w);
    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;
    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

const float noiseFreq = 0.5;
const float noiseStrength = 2.;
const float noiseTime = 0.1;

void main() {
	vUv = uv;

	float progressVal = easeInQuart(max(uProgress + center.y, 0.)) * 0.001;
	vec3 pos = position;

    vec3 objectNormal = vec3(normal);
    vec3 transformedNormal = objectNormal;
    transformedNormal = normalMatrix*transformedNormal;

	vec3 displacement = vec3(
        pnoise(noiseFreq * center.rgb + vec3(0., uTime * noiseTime, 0.), vec3(101.0)) * noiseStrength * clamp(progressVal - 0.5, 0., 1.),
        pnoise(noiseFreq * center.rgb + vec3(0., uTime * noiseTime, 0.), vec3(202.0)) * noiseStrength * clamp(progressVal - 0.5, 0., 1.),
        pnoise(noiseFreq * center.rgb + vec3(0., uTime * noiseTime, 0.), vec3(303.0)) * noiseStrength * clamp(progressVal - 0.5, 0., 1.)
    );

	vec3 translatePos = vec3(0.);
	translatePos.z += progressVal * random.z * sin(sign(letterCenter.z) * random.z ) * 0.1 + displacement.z;
	translatePos.x += progressVal * random.x * sign(letterCenter.x) * random.x * 0.0005 + displacement.x;
	translatePos.y += progressVal * random.y * 0.05 + displacement.y;

	if(center.x > 0. || center.x < 0.){
		pos = position - center;

		// pos = rotate(pos, center, progressVal);
		pos = rotate(pos, center, progressVal * 0.02 + displacement.x * 0.2);
		// pos = rotate(pos, center, uMouse.x);
		objectNormal = rotate(objectNormal, center, progressVal * 0.02 + displacement.x * 0.2);
		pos += center;
	}

	pos.z -= letterCenter.z;
	pos.x -= letterCenter.x;
	pos.y -= letterCenter.y;

	pos = rotate(pos, vec3(0., 1., 0.), appearProgress(uAppear) + -uMouse.x * 0.2 * clamp(1. - progressVal * 0.5, 0., 1.));
	pos = rotate(pos, vec3(1., 0., 0.), uMouse.y * 0.2 * clamp(1. - progressVal * 0.5, 0., 1.));

	pos.z += letterCenter.z;
	pos.x += letterCenter.x;
	pos.y += letterCenter.y;

	pos.z += translatePos.z - easeInBack(appearProgress(uAppear)) * 50.;
	pos.x += translatePos.x;
	pos.y += translatePos.y;

	


	vec4 worldPosition = modelMatrix * vec4( pos, 1.0);

	// #ifndef REFRACT
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		}
		else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 reflectNormal = inverseTransformDirection( transformedNormal, viewMatrix );
		vReflect = reflect( cameraToVertex, reflectNormal );
	// #endif

	eyeVector = normalize(worldPosition.xyz - cameraPosition);
	worldNormal = normalize( modelViewMatrix * vec4(objectNormal, 0.0)).xyz;

	vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
	vViewPosition = - mvPosition.xyz;
	
	gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
	vBackface = clamp(progressVal * 10., 0., 1.);
	zVal = pos.z;
}