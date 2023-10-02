#include <defaultFrag>
#include <dynamicBaseFragPars>
uniform sampler2D envMap;
uniform sampler2D uMap;
uniform sampler2D textureMap;
uniform sampler2D normalMap;
uniform sampler2D backfaceMapBroken;
uniform sampler2D backfaceMap;
uniform sampler2D matCapMap;
uniform sampler2D uMatcap;
uniform vec2 resolution;
uniform float uProgress;
uniform float uFresnelVal;
uniform float uRefractPower;
uniform float uBackfaceTest;

varying vec3 worldNormal;
varying vec3 eyeVector;
varying vec3 viewDirection;
varying vec2 vUv; 
varying vec3 worldPosition;
varying float vBackface;
varying float zVal;


// float ior = 2.4;
// float a = .5;
// float diffuse = 0.2;

float ior = .5;
float diffuse = 0.2;

vec3 fogColor = vec3(1.0);
vec3 reflectionColor = vec3(1.0);

float Fresnel(vec3 eyeVector, vec3 worldNormal) {
	return pow( 1.0 + dot( eyeVector, worldNormal), 3.0 );
}

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

vec2 matcap(vec3 eye, vec3 normal) {
  vec3 reflected = reflect(eye, normal);
  float m = 2.8284271247461903 * sqrt( reflected.z+1.0 );
  return reflected.xy / m + 0.5;
}

void main() {
	float a = .5;
	// get screen coordinates
	vec2 uv = gl_FragCoord.xy / resolution;
	float noiseVal = noise(uv);

	float fade = step(.5, vUv.y);

	vec4 normalMap = texture2D(normalMap, vUv);

    // sample backface data from texture
	
	vec4 backfaceTFull = texture2D(backfaceMap, uv);
	vec4 backfaceTBroken = texture2D(backfaceMapBroken, uv);
	vec4 backfaceTex = mix(backfaceTFull, backfaceTBroken, vBackface);
	vec3 backfaceNormal = backfaceTex.rgb;
	float backfaceDepth = backfaceTex.a;


	float frontfaceDepth = worldPosition.z;

	vec3 normal = mix(worldNormal * (1.0 - a) - backfaceNormal * a, worldNormal * (1.0 - a) - backfaceNormal * a, 1.) ;
	// calculate refraction and add to the screen coordinates
	vec3 refracted = refract(eyeVector, normal, 1.0/ior);
	uv += refracted.xy;

	vec2 matCapUv = matcap(eyeVector, normal).xy;
	vec4 matCap = texture2D(matCapMap, uv);

	// sample the background texture
	vec4 tex = texture2D(envMap, uv);

	vec4 final = tex;

	// calculate the Fresnel ratio
	float f = Fresnel(eyeVector, normal);

    // calculate thickness
	vec3 thickness = vec3(frontfaceDepth - backfaceDepth) * 0.1 + 0.9;

	final.rgb = mix(tex.rgb, fogColor, thickness * diffuse);
	// mix the refraction color and reflection color
	final.rgb = mix(final.rgb, reflectionColor, f * uFresnelVal);


	vec3 refractCol = vec3( 0.0 );
	vec2 screenUv = uv;
	vec2 refractUv = screenUv;

	float slide;
	vec2 refractUvR;
	vec2 refractUvG;
	vec2 refractUvB;
	float refractPower = uRefractPower;
	vec2 refractNormal = refracted.xy * ( 1.0 - refracted.z * 0.85 );

	#pragma unroll_loop_start
	for ( int i = 0; i < 16; i ++ ) {
		
		slide = (float( UNROLLED_LOOP_INDEX ) * 0.1 )/ 16.0 + noise( screenUv ) * .1;

		refractUvR = refractUv - refractNormal * ( refractPower + slide * 1.0 ) * 0.5;
		refractUvG = refractUv - refractNormal * ( refractPower + slide * 1.5 ) * 0.5;
		refractUvB = refractUv - refractNormal * ( refractPower + slide * 2.0 ) * 0.5;

		refractCol.x += texture2D( envMap, refractUvR ).x;
		refractCol.y += texture2D( envMap, refractUvG ).y;
		refractCol.z += texture2D( envMap, refractUvB ).z;

	}
	#pragma unroll_loop_end
	refractCol /= float( 16 );

	refractCol.rgb = mix(refractCol.rgb, fogColor, thickness * diffuse);
	// mix the refraction color and reflection color
	refractCol.rgb = mix(refractCol.rgb, matCap.rgb, f * uFresnelVal);

	vec3 viewDir = normalize( vViewPosition );

	#ifdef USE_MATCAP
		vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
		vec3 y = cross( viewDir, x );
		vec2 uvMat = vec2( dot( x, normal ), dot( y, normal ) ) * 0.5 + 0.5; // 0.495 to remove artifacts caused by undersized matcap disks

		vec4 matcapColor = texture2D( uMatcap, uvMat );

		#ifdef USE_MATCAP_EXTRA
			vec4 extraMatcap = texture2D( tMatcapExtra, uvMat );
		#endif
	#else
		vec4 matcapColor = vec4(1.); // default if matcap is missing
	#endif

	#ifdef USE_MATCAP

		vec3 outgoingLight;

		if(uBlendMode == 0) {
			outgoingLight = blendSoftLight(refractCol.rgb, matcapColor.rgb, uDiffuseMatcapBlend);
		} else if(uBlendMode == 1){
			outgoingLight = blendLinearLight(refractCol.rgb, matcapColor.rgb, uDiffuseMatcapBlend);
		} else if(uBlendMode == 2){
			outgoingLight = blendLighten(refractCol.rgb, matcapColor.rgb, uDiffuseMatcapBlend);
		} else if(uBlendMode == 3){
			outgoingLight = blendOverlay(refractCol.rgb, matcapColor.rgb, uDiffuseMatcapBlend);
		} else if(uBlendMode == 4){
			outgoingLight = blendAdd(refractCol.rgb, matcapColor.rgb, uDiffuseMatcapBlend);
		} else {
			outgoingLight = blendMultiply(refractCol.rgb, matcapColor.rgb, uDiffuseMatcapBlend);
		}

		#ifdef USE_MATCAP_EXTRA
			outgoingLight = blendSoftLight(outgoingLight, extraMatcap.rgb, uMatcapExtraBlend);
		#endif

		#ifdef USE_SHADOW
			outgoingLight = blendMultiply(outgoingLight, shadowOverlay.rgb, uShadowBlend);
		#endif

		// vec3 outgoingLight = blendAdd(blendSoftLight(diffuseColor.rgb, matcapColor.rgb, uDiffuseMatcapBlend), specular, uEnvMapBlend);
		// vec3 outgoingLight = blendAdd(blendOverlay(diffuseColor.rgb, matcapColor.rgb, uDiffuseMatcapBlend), specular, uEnvMapBlend);
	#else
		// vec3 outgoingLight = refractCol.rgb;
	#endif
	
	vec4 map = texture2D(uMap, vUv);
	// gl_FragColor = map;	
	outgoingLight = mix(map.rgb, outgoingLight, 1.);

	gl_FragColor = vec4(final.rgb, 1.0);

	float zthreshold = smoothstep(-3., -2., zVal);
	zthreshold = mix(zthreshold, 1., vBackface);
	float glowThreshold = smoothstep(-2., -1., zVal);
	glowThreshold = mix(glowThreshold, 1., vBackface);

	outgoingLight = mix(vec3(1.), outgoingLight, min(glowThreshold, 1.));
	gl_FragColor = vec4(outgoingLight, zthreshold);
	// gl_FragColor = vec4(vec3(backfaceBroken), 1.);	

	

}