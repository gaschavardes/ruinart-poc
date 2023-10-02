import { RawShaderMaterial } from 'three'
import { mergeDeep } from '../../utils'

import vertexShader from './vert.glsl'
import fragmentShader from './frag.glsl'

export default class GradientMaterial extends RawShaderMaterial {
	constructor(options = {}) {
		options = mergeDeep(
			{
				uniforms: {
					velocity: options.waterTexture,
					boundarySpace: options.boundarySpace
				},
				defines: {
				}
			}, options)

		super({
			vertexShader,
			fragmentShader,
			uniforms: options.uniforms,
			defines: options.defines,
			// depthWrite: false
		})

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