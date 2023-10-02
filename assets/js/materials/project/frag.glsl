#include <defaultFrag>
#define PI 3.1415926538
uniform vec3 uColor;
uniform float uTime;
uniform sampler2D uMap;
uniform vec2 uResolution;
varying vec3 vNormal;
varying vec2 vUv;
varying sampler2D uTexture

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

const float noiseFreq = 0.5;
const float noiseStrength = .1;
const float noiseTime = 0.1;

void main() {
	vec2 screenCoord = vec2(
		gl_FragCoord.x / uResolution.x,
		gl_FragCoord.y / uResolution.y
	);

	vec4 textureMain = texture2D(uTexture, gl_FragCoord.xy);

	float noiseFact = smoothstep(0.9, 0.8, screenCoord.y) *  smoothstep(0.1, 0.2, screenCoord.y);

	float noise = random(vec2(screenCoord.x +  (1. - noiseFact) * 10., screenCoord.y ));

	vec4 texture = texture2D(uMap, vUv);

    gl_FragColor = vec4(noise * (1. - noiseFact), 0., 0., 1.);
	gl_FragColor = textureMain * (noiseFact);
}
