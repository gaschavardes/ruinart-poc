#include <defaultFrag>

uniform vec3 uColor;
uniform vec2 uResolution;
varying vec3 vNormal;
varying vec3 vColor;
varying float vProgress;
uniform sampler2D uTexture;
varying vec2 vUV1;
varying vec2 vUV2;

void main() {
    vec2 screenUV = gl_FragCoord.xy / uResolution;
	float noiseFact = smoothstep(0.9, 0.8, screenUV.y) *  smoothstep(0.1, 0.2, screenUV.y);

	float highlight = smoothstep(0.1, 0.05, vProgress) * smoothstep(0.0001, 0.01, vProgress);

	vec4 textureMain = texture2D(uTexture, vUV1);
	// vec4 textureMain2 = texture2D(uTexture, vUV2);
	// vec4 textureMain = texture2D(uTexture, gl_FragCoord.xy);

	gl_FragColor = vec4(vec3(clamp(textureMain.rgb, vec3(0.), vec3(0.97))) + highlight * vec3(100.), 1.);
}