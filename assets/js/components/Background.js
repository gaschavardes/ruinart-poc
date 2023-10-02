import { Mesh, Color, PlaneGeometry, DataTexture, TextureLoader} from 'three'
import { BackgroundMaterial } from '../materials'
import store from '../store'
import data from '~/static/data/data1.json'
import text1 from '~/static/image/text1.jpeg'
// import { copyObjectDataTransforms } from '../utils'

export default class Background extends Mesh {
	constructor() {
		super(
			new PlaneGeometry(),
			new BackgroundMaterial({
			})
		)
		this.textures = []

		this.setTexture(data)
		this.createTexture(text1)


		this.position.set(0, 0, 0)
		this.scale.setScalar(100)
		this.globalUniforms = {
			uColor: { value: new Color(0xf3ff8f) },
		}
		this.renderOrder = 1
		this.appaearProgress = 0
		this.load()
		store.RAFCollection.add(this.animate, 0)
		this.scroll = 0

	

	}

	build() {
		this.material.uniforms.uMap.value = store.MainScene.backgroundTexture

		this.material.uniforms.uDataTexture.value = this.dataTexture
		this.material.uniforms.uMap.value = this.textures[0]
		this.material.uniforms.uMap1.value = this.textures[0]
		this.material.uniforms.uMap2.value = this.textures[0]
		this.material.uniforms.uMap3.value = this.textures[0]
		this.material.uniforms.uMap4.value = this.textures[0]
		this.material.uniforms.uMap5.value = this.textures[0]
		this.material.uniforms.uMap6.value = this.textures[0]
	}

	mouseMove = () => {
		
	}

	animate = () => {
		this.material.uniforms.uScroll.value = this.scroll
		console.log(this.scroll)
	}

	createTexture = (text) => {
		const texture = new TextureLoader().load(text ); 
		console.log(texture)
		this.textures.push(texture)
	}

	setTexture = (data) => {
		const width = data.length
		let height = 0
		const wholeData = []
		data.forEach((el, i) => {
			height = el.filtered.length
			wholeData.push(...el.filtered)
		});
		console.log(wholeData)
		const size = width * height
		const dataArray = new Uint8Array(4 * size)
		const color = new Color( 0xffffff );

		const r = Math.floor( color.r * 255 );
		const g = Math.floor( color.g * 255 );
		const b = Math.floor( color.b * 255 );

		for ( let i = 0; i < wholeData.length; i ++ ) {
			const stride = i * 4;
			dataArray[ stride ] = wholeData[i] * 255;
			dataArray[ stride + 1 ] = wholeData[i] * 255;
			dataArray[ stride + 2 ] = wholeData[i] * 255;
			dataArray[ stride + 3 ] = 1;
		}
		this.dataTexture = new DataTexture( dataArray, width, height );
		console.log(dataArray)
		console.log(this.dataTexture)

		this.dataTexture.needsUpdate = true;
	}

	load() {
		this.assets = {
			models: {},
			textures: {}
		}
	}
}