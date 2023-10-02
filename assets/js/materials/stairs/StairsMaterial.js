import { ShaderMaterial, Vector2, DoubleSide } from 'three'
import { mergeDeep } from '../../utils'

import vertexShader from './vert.glsl'
import fragmentShader from './frag.glsl'
import store from '../../store'

export default class StairsMaterial extends ShaderMaterial {
	constructor(options = {}) {
		options = mergeDeep(
			{
				uniforms: {
					tMap: {value: null},
					uScroll: { value: 1},
					uTime: store.WebGL.globalUniforms.uTime,
					random: { value: 0},
					ratio: { value: new Vector2()},
					id: { value: 0},
					resolution: { value: new Vector2},
					uCount: { value: 0},
					uWindowRatio: { value: 0},
					uIndex : { value: options.index % 2}
				},

				defines: {
					USE_DIFFUSE: false,
					USE_NORMAL: false,
					USE_MATCAP: false,
					USE_ENV: false,
					USE_ROUGH: false,
					USE_MATCAP_EXTRA: false,
				}
			}, options)

		super({
			vertexShader,
			fragmentShader,
			uniforms: options.uniforms,
			fog: false,
			transparent: true,
			side: DoubleSide,
			alphaTest: 1,
		})
		console.log(options.index)
		this.globalUniforms = options.globalUniforms
		this.uniforms = Object.assign(this.uniforms, this.globalUniforms)
	}

	/*
		Ensure correct cloning of uniforms with original references
	*/
	clone(uniforms) {
		const newMaterial = super.clone()
		newMaterial.uniforms = Object.assign(newMaterial.uniforms, this.globalUniforms)
		newMaterial.uniforms = Object.assign(newMaterial.uniforms, uniforms)
		return newMaterial
	}
}