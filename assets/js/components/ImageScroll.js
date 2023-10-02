import { Group, MathUtils, InstancedMesh, Object3D, InstancedBufferAttribute, RepeatWrapping, PlaneGeometry, TextureLoader, Mesh, Vector2 } from 'three'
import text1 from '~/static/image/text1.jpeg'
import text2 from '~/static/image/text2.jpeg'
import store from '../store'
import { StairsMaterial } from '../materials'
export default class Stairs extends Group {
	constructor() {
		super()

		this._instanceDummy = new Object3D()
		this.scroll = 1
		this.imgCount = 50
		this.meshes = []

		window.addEventListener("mousewheel", (e) => {
			this.scroll += e.deltaY * 0.01
		})
		this.load()
		this.viewSize = this.getViewSize()
	}

	build() {
		store.RAFCollection.add(this.animate, 0)
		const objectUniforms = {
			tMap: { value: new TextureLoader().load(text1) },
		}
	
		const ratio = []
		const id = []
		const random = []
		const windowRatio = store.window.w / store.window.h
		for (let i = 0; i < this.imgCount ; i++) {

			const meshUniforms = {
				tMap: { value: new TextureLoader().load(text1) },
				random: {value: Math.random() * Math.PI},
				id: { value : i},
				uCount: { value: this.imgCount },
				resolution: { value: new Vector2(store.window.w, store.window.h, )},
				// uScaleToViewSize : { value: new Vector2( this.viewSize.width / widthViewUnit - 1,  viewSize.height / heightViewUnit - 1)}
			}
			
			const mesh = new Mesh(
				new PlaneGeometry(2, 2, 32, 32),
				new StairsMaterial({
					uniforms: meshUniforms,
					index: i
					
				}),
			)
			const path = i === 0 ? text2 : text1
			const texture = new TextureLoader()
			texture.load(
				path,
				(tex) => {
					mesh.material.uniforms.tMap.value = tex
					mesh.material.uniforms.ratio.value = new Vector2(tex.image.width, tex.image.height)
				}
			)

			this.meshes.push(mesh)
			this.add(mesh)
		}
	}

	load() {
		this.assets = {
			models: {},
			textures: {}
		}

		const textures = {
			normal: 'step/normal',
			base: 'step/baseColor'
		}

		// for (const key in textures) {
		// 	store.AssetLoader.loadKtxTexture((`${store.publicUrl}webgl/textures/${textures[key]}.ktx2`), { wrapping: RepeatWrapping }).then(texture => {
		// 		this.assets.textures[key] = texture
		// 	})
		// }
	}
	animate = () => {
		this.meshes.forEach(el => {
			el.material.uniforms.uScroll.value = this.scroll
		})
		// this.instance.material.uniforms.uScroll.value = this.scroll
	}

	getViewSize() {
		const fovInRadians = (store.MainScene.camera.fov * Math.PI) / 180;
		const height = Math.abs(
		  store.MainScene.camera.position.z * Math.tan(fovInRadians / 2) * 2
		);
	
		return { width: height * store.MainScene.camera.aspect, height };
	  }

	destroy() {
	}
}
