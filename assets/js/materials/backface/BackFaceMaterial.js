import { ShaderMaterial, BackSide, Vector2 } from 'three'
import vertexShader from '../glass/vert.glsl'
import fragmentShader from './frag.frag'

export default class BackFaceMaterial extends ShaderMaterial {
	constructor() {
		super({
			vertexShader,
			fragmentShader,
			side: BackSide,
			uniforms: {
				uTime: { value: 0 },
				uProgress: { value: 0 },
				uStartingTime: { value: 0 },
				uAppear: { value: 0 },
				uMouse: { value: Vector2}
			}
		})
	}
}