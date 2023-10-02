#include <defaultVert>

varying vec3 vNormal;
varying vec3 vColor;
varying float vProgress;
attribute vec3 colorVal;
attribute float random;
attribute mat4 instanceMatrix;
uniform vec2 uResolution;
uniform float uTime;

attribute float aID;
attribute vec2 aUVID;
varying vec2 vUV1;
varying vec2 vUV2;
uniform vec2 uSpriteSize;
uniform float uYpos;

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

const float noiseFreq = 1.;
const float noiseStrength = 20.;
const float noiseTime = 0.1;

mat4 translationMatrix(vec3 axis)
{

		return mat4(1., 0., 0., 0.,
					0., 1., 0., 0.,
					0., 0., 1., 0., 
					axis.r, axis.g, axis.b, 1.);
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
mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

void main()	{
    #include <normalsVert>

	vColor = colorVal;

	vec4 newPos = vec4(position, 1.);

	vec4 worldPosition = vec4(position, 1.);
	worldPosition = instanceMatrix * worldPosition;
	worldPosition = modelViewMatrix * instanceMatrix * newPos;

	float noiseFact = 1. - smoothstep(5., 3., worldPosition.y) * smoothstep(-5., -3., worldPosition.y);
	// newPos.x += (1. - noiseFact) * 10.;

	float borderNoise =  smoothstep( uSpriteSize.x * 0.01, 0., aUVID.x)
	 + smoothstep( uSpriteSize.x * 0.99, uSpriteSize.x, aUVID.x) 
	 + smoothstep( uSpriteSize.y * 0.99, uSpriteSize.y, aUVID.y)
	 + smoothstep( uSpriteSize.y * 0.01, 0., aUVID.y);
	borderNoise *= 0.03;

	vec3 displacement = vec3(
        pnoise(noiseFreq * instanceMatrix[3].rgb + vec3(0., uTime * noiseTime, 0.), vec3(101.0, random, random)) * noiseStrength * 30. * (noiseFact),
       - abs(pnoise(noiseFreq * instanceMatrix[3].rgb + vec3(0., uTime * noiseTime, 0.), vec3(202.0, random, random)) * noiseStrength)  * (noiseFact),
        pnoise(noiseFreq * instanceMatrix[3].rgb + vec3(0., uTime * noiseTime, 0.), vec3(202.0)) * noiseStrength * (noiseFact) * 0.1
    );
	mat4 instance = instanceMatrix;

	displacement *= rotateZ(sin(-uYpos * 0.1));
	instance *= translationMatrix(displacement);

    vUV1 = (uv + aUVID) / uSpriteSize;

    gl_Position = projectionMatrix * modelViewMatrix * instance * newPos;
	vProgress = noiseFact;
}