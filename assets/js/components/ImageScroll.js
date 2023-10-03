import { Group, MathUtils, InstancedMesh, Object3D, InstancedBufferAttribute, RepeatWrapping, PlaneGeometry, TextureLoader, Mesh, Vector2 } from 'three'
import text1 from '~/static/image/text1.jpeg'
import text2 from '~/static/image/text2.jpeg'
import img1 from '~/static/image/img1.jpg'
import img2 from '~/static/image/img2.jpg'
import img3 from '~/static/image/img3.jpg'
import img4 from '~/static/image/img4.jpg'
import img5 from '~/static/image/img5.jpg'
import img6 from '~/static/image/img6.jpg'
import store from '../store'
import { StairsMaterial } from '../materials'
export default class Stairs extends Group {
	constructor() {
		super()

		this.scroll = 1
		this.easedMouse = new Vector2()
		this.easedMouseTemp = new Vector2()
		this.mouseVelocity = new Vector2()
		this.imgCount = 6
		this.meshes = []
		this.images = [img1, img2, img3, img4, img5, img6]

		window.addEventListener("mousewheel", (e) => {
			this.scroll += e.deltaY * 0.01
		})
		this.load()
		this.viewSize = this.getViewSize()
	}

	build() {
		store.RAFCollection.add(this.animate, 0)
	
		const ratio = []
		const id = []
		const random = []
		const windowRatio = store.window.w / store.window.h
		for (let i = 0; i < this.imgCount ; i++) {

			const meshUniforms = {
				random: {value: Math.random() * Math.PI},
				id: { value : i},
				uCount: { value: this.imgCount },
				resolution: { value: new Vector2(store.window.w, store.window.h)},
				uWindowRatio: { value: windowRatio}
				// uScaleToViewSize : { value: new Vector2( this.viewSize.width / widthViewUnit - 1,  viewSize.height / heightViewUnit - 1)}
			}
			
			const mesh = new Mesh(
				new PlaneGeometry(1 * windowRatio, 1, 32, 32),
				new StairsMaterial({
					uniforms: meshUniforms,
					index: i
				}),
			)
			mesh.scale.set(2, 2, 2)
			const path = this.images[i % 6]
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
		this.easedMouseTemp.subVectors(store.pointer.glNormalized, this.easedMouse)
		this.easedMouseTemp.multiplyScalar(0.2)
		this.easedMouse.addVectors(this.easedMouseTemp, this.easedMouse)
		this.mouseVelocity.subVectors(store.pointer.glNormalized, this.easedMouse) 

		this.meshes.forEach(el => {
			el.material.uniforms.uScroll.value = this.scroll
			el.material.uniforms.uMouse.value = this.mouseVelocity
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
