
varying vec2 vUv;
varying vec2 vRatio;
uniform sampler2D tMap;
uniform float uMatcapExtraBlend;
varying float vOpacity;
uniform vec2 resolution;
uniform float uWindowRatio;
varying float defY;
varying float defX;

void main() {

	vec2 ratioImg = vec2(
		min((resolution.x / resolution.y) / (vRatio.x / vRatio.y), 1.0),
		min((resolution.y / resolution.x) / (vRatio.y / vRatio.x), 1.0)
    );

	float ratio = ratioImg.x/ratioImg.y;

	vec2 uv = vUv;
	// uv.y -= defY;
	// uv.y += sign(uv.y) * sin(uv.y);
 	uv.x *= ratioImg.x + (1.0 - ratioImg.x) * 0.5;
	uv.y *= ratioImg.y + (1.0 - ratioImg.y) * 0.5;
	// uv.y -= (0.5 - (1. / ratio) * 0.5) * ratio;


	vec2 ratioUv =  vec2(uv.x, (uv.y - 0.5) * vRatio.x / vRatio.y);
	vec4 map = texture2D( tMap, uv); // overrides both flatShading and attribute normals
	float alpha = step(uv.x, 1.) * step(0., uv.x) * step(0., uv.y) * step(uv.y, 1.);
	gl_FragColor = vec4(map);
	// gl_FragColor.rgb = vec3(alpha, 0., 0.);
	gl_FragColor.a = alpha * vOpacity;
	// gl_FragColor = vec4(1., 0., 0., 1.);
}