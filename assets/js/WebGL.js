import { ClampToEdgeWrapping, Clock, LinearFilter, LinearMipmapLinearFilter, Texture, WebGLRenderer, LinearSRGBColorSpace, LinearToneMapping  } from 'three'
import { setupShaderChunks } from './materials'
import store from './store'
import { E, qs } from './utils'
import GlobalEvents from './utils/GlobalEvents'

export default class WebGL {
	constructor() {
		this.dom = {
			canvas: qs('canvas#gl')
		}

		console.log('WEBGL', store)

		this.setup()

		E.on('App:start', this.start)
	}

	setup() {
		console.log(this.dom.canvas)
		this.renderer = new WebGLRenderer({ alpha: true, antialias: true, canvas: this.dom.canvas, powerPreference: 'high-performance', stencil: false })
		this.renderer.setPixelRatio(store.window.dpr >= 2 ? 2 : store.window.dpr)
		this.renderer.setSize(store.window.w, store.window.h)
	

		this.renderer.toneMappingExposure = 1
		this.clock = new Clock()

		this.globalUniforms = {
			uDelta: { value: 0 },
			uTime: { value: 0 }
		}

		setupShaderChunks()
	}

	start = () => {
		this.addEvents()
	}

	addEvents() {
		E.on(GlobalEvents.RESIZE, this.onResize)
		store.RAFCollection.add(this.onRaf, 0)
	}

	onRaf = (time) => {
		this.clockDelta = this.clock.getDelta()
		this.globalUniforms.uDelta.value = this.clockDelta > 0.016 ? 0.016 : this.clockDelta
		this.globalUniforms.uTime.value = time
		
	}

	onResize = () => {
		this.renderer.setSize(store.window.w, store.window.h)
	}

	generateTexture(texture, options = {}, isKtx = false) {
		if (texture instanceof HTMLImageElement) {
			texture = new Texture(texture)
		}
		texture.minFilter = options.minFilter || (isKtx ? LinearFilter : LinearMipmapLinearFilter)
		texture.magFilter = options.magFilter || LinearFilter
		texture.wrapS = texture.wrapT = options.wrapping || ClampToEdgeWrapping
		texture.flipY = options.flipY !== undefined ? options.flipY : true
		// texture.encoding = options.colorSpace || LinearEncoding
		this.renderer.initTexture(texture)
		return texture
	}
}