#include <defaultFrag>
#pragma glslify: snoise2 = require(glsl-noise/simplex/2d)
#pragma glslify: blur = require('glsl-fast-gaussian-blur')
#pragma glslify: ease = require(glsl-easings/sine-in-out)
uniform vec3 uColor;
varying vec3 vNormal;
varying vec2 vUv;
uniform sampler2D envFbo;
uniform sampler2D uMap;
uniform sampler2D uMap1;
uniform sampler2D uMap2;
uniform sampler2D uMap3;
uniform sampler2D uMap4;
uniform sampler2D uMap5;
uniform sampler2D uMap6;
uniform vec2 resolution;
uniform float uTime;
uniform float uAppear;
uniform float uScroll;
uniform sampler2D uDataTexture;

const int MAX_STEPS = 100;
const float MAX_DIST = 2000.0;
const float SURFACE_DIST = .0001;


// exponential smooth min (k=32)
float smin( float a, float b, float k )
{
    float res = exp2( -k*a ) + exp2( -k*b );
    return -log2( res )/k;
}

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, s, -s, c);
	return m * v;
}

float scene(vec3 p) {
	// float plane = p.y + 3. + sin((p.x + p.z) * 2.) * 0.1;
	p = vec3(p.x, rotate(p.yz, -0.5));
	float texture = texture2D(uDataTexture, rotate(p.xz * 0.001 - vec2(.8), PI)).r;
	float plane = p.y + 10. + texture * 5.;
	float smoothPlane = p.y + 10.;

	float outgoing = smin(smoothPlane, plane, 5.);
	
	// float plane =  p.y + 10. + snoise2(p.zx * 0.002) * 20. + snoise2(rotate(p.xz * 0.01, PI * 0.5 )) * 10. + snoise2(rotate(p.xz * 0.1, PI * 2.)) * .3;

	// float initY = 3.;
	// float sphere1 = sdSphere(p - vec3(1.0 + cos(uTime), 0.7, 0.0), 1.0);
	// float sphere2 = sdSphere(p + vec3(1.0, 0.5 + sin(uTime)/2.0, 0.0), .5);
	// float sphere3 = sdSphere(p + vec3(0., 3., 0.) + vec3(1.0, 0.5 - sin(uTime)/2.0, 0.0), .5);

	// float sphere =  sdTorus(p + vec3(0., initY, 0.) + vec3(1.0, 0.5, 0.0), vec2(.5, 0.05));
	// float outgoing = sphere;

	// for(int i = 1; i < 20; i++) {
	// 	// float noise = snoise2(vec2(float(i), float(i)));
	// 	sphere = sdTorus(p + vec3(0., initY - float(i) * 0.3, 0.) + vec3(random[i] * 0.01, 0.5, 0.0), vec2(max(.1, abs(random[i])), 0.));
	// 	outgoing = smin(outgoing, sphere, 20.);
	// }

	// float distance1 = smin(sphere1, sphere2, 1.);
	// float distance2 = smin(distance1, sphere3, 1.);

	// outgoing += snoise2( p.yy + uTime * 0.5) / 5.0;
	// float distance2 = min(plane, distance1);
	return plane;
}

float softShadows(vec3 ro, vec3 rd, float mint, float maxt, float k ) {
  float resultingShadowColor = 1.0;
  float t = mint;
  for(int i = 0; i < 50; i++) {
	  if(t > maxt) {
		break;
	  }
      float h = scene(ro + rd*t);
      if( h < 0.001 )
          return 0.0;
      resultingShadowColor = min(resultingShadowColor, k*h/t );
      t += h;
  }
  return resultingShadowColor ;
}


float raymarch(vec3 ro, vec3 rd) {
  float dO = 0.0;
  vec3 color = vec3(0.0);
  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 p = ro + rd * dO;

    float dS = scene(p);
    dO += dS;

    if(dO > MAX_DIST || dS < SURFACE_DIST) {
        break;
    }
  }
  return dO;
}

vec3 getNormal(vec3 p) {
  vec2 e = vec2(.01, 0);

  vec3 n = scene(p) - vec3(
    scene(p-e.xyy),
    scene(p-e.yxy),
    scene(p-e.yyx));

  return normalize(n);
}

float fog(float color, float distance) {
	return distance * color + ( 1. - distance);
}

void main() {
	vec2 uv = gl_FragCoord.xy/resolution.xy - .5 ;
	vec2 uv1 = gl_FragCoord.xy/resolution.xy;
    float ratio = resolution.x / resolution.y;
	// uv = vec2(uv.x * ratio, uv.y );
	vec4 texture;
	float alpha;
	for(int i = 1; i < 4; i++) {
		vec2 uvTest = (uv - 0.5) *  (ease(clamp(uScroll * 0.001 - float(i) * 0.01, 0., 1.)) * 100. + 1.) * 0.6+ 0.5;
		alpha = step(uvTest.x, 1.) * step(0., uvTest.x) * step(0., uvTest.y) * step(uvTest.y, 1.);
		vec4 activeTexture = texture2D(uMap, uvTest);
		texture = mix(activeTexture, texture, alpha);

	}

	gl_FragColor = texture;
	gl_FragColor.a = alpha;
	// gl_FragColor = vec4(alpha);
	// gl_FragColor = vec4(vec3(fract(sin(uv.x * 10.))), 1.0);

}
