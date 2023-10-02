import { ShaderMaterial, Vector2 } from 'three'
import store from '../../store'
import vertexShader from './vert.glsl'
import fragmentShader from './frag.glsl'

export default class GlassMaterial extends ShaderMaterial {
	constructor(options) {
		super({
			vertexShader,
			fragmentShader,
			transparent: true,
			uniforms: {
				envMap: { value: options.envMap },
				uMap: {value: options.uMap},
				uMouse: { value: new Vector2() },
				resolution: { value: new Vector2(options.resolution[0], options.resolution[1]) },
				backfaceMapBroken: { value: options.backfaceMapBroken },
				backfaceMap: { value: options.backfaceMap },
				normalMap: { value: options.normalMap },
				uAppear: { value: 0 },
				uTime: { value: store.WebGL.globalUniforms.uTime.value },
				uProgress: { value: 0 },
				uBackfaceTest: { value: 0 },
				uFresnelVal: { value: options.fresnelVal },
				uStartingTime: { value: 0 },
				uRefractPower: { value: options.refractPower },
				uBlendMode: { value: 1},
				uDiffuseMatcapBlend: { value : 0.6},
				uMatcap: {value: options.matcap}
			},
			defines: {
				REFRACT: options.refract,
				USE_NORMAL: true,
				USE_MATCAP: true,
			}
		})
	}
}