import { AdditiveBlending, Color, RawShaderMaterial, Vector2 } from 'three'
import { mergeDeep } from '../../utils'
import store from '../../store'
import vertexShader from './vert.glsl'
import fragmentShader from './frag.glsl'

export default class BasicMaterial extends RawShaderMaterial {
	constructor(options = {}) {
		options = mergeDeep(
			{
				uniforms: {
					uTexture: options.uniforms.videoTexture,
					uColor: { value: new Color(0xffffff) },
					uResolution: {value: new Vector2(store.window.w * store.WebGL.renderer.getPixelRatio(), store.window.h * store.WebGL.renderer.getPixelRatio())},
					uTime: store.WebGL.globalUniforms.uTime,
					uSpriteSize: options.uniforms.spriteSize,
					uYpos: {value: 0}
				},
				defines: {
				}
			}, options)


		super({
			vertexShader,
			fragmentShader,
			uniforms: options.uniforms,
			defines: options.defines,
			toneMapped: false,
			blending: AdditiveBlending 
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