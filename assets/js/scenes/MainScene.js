/* eslint-disable */
import { Color, PerspectiveCamera, CameraHelper, OrthographicCamera, Scene, AmbientLight, SpotLight, GridHelper, Vector2, ShaderMaterial, WebGLRenderTarget} from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import ImageScroll from '../components/ImageScroll'
import store from '../store'
import { E } from '../utils'
import GlobalEvents from '../utils/GlobalEvents'
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass'
import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass'
import screenFxVert from '../../../glsl/includes/screenFx/vert.glsl'
import screenFxFrag from '../../../glsl/includes/screenFx/frag.glsl'

export default class MainScene extends Scene {
	constructor() {
		super()

		store.MainScene = this
		this.options = {
			controls: window.urlParams.has('controls')
		}

		this.camera = new PerspectiveCamera(45, store.window.w / store.window.h, 2, 100)
		this.camera.position.z = 2
		this.add(this.camera)


		this.orthoCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
		// this.orthoCamera.position.z = 5

		this.activeCamera = this.orthoCamera

		/* Debug tools */
		this.cameraHelper = new CameraHelper(this.camera)
		this.cameraHelper.visible = false
		this.add(this.cameraHelper)

		this.devCamera = new PerspectiveCamera(45, store.window.w / store.window.h, 1, 1000)
		this.devCamera.position.z = 10
		this.devCamera.position.y = 3
		this.add(this.devCamera)

		this.controls = new OrbitControls(this.devCamera, store.WebGL.renderer.domElement)
		this.controls.target.set(0, 0, 0)
		this.controls.enabled = this.options.controls
		this.controls.enableDamping = true

		this.background = new Color(0x222222)

		/* Add scene components */
		this.components = {
			imageScroll: new ImageScroll()
			// background: new Background(),
			// letter: new Letter(),
			// projects: new Projects()
		}

		this.load()

		E.on('App:start', () => {
			this.createFbo()
			this.build()
			this.addEvents()
		})
	}

	build() {
		this.composer = new EffectComposer(store.WebGL.renderer)
		this.composer.setSize(store.window.w, store.window.h)
		// Build components and add to scene
		for (const key in this.components) {
			this.components[key].build(this.objectData)
			this.add(this.components[key])
		}

		// this.buildPasses()
	}

	buildPasses() {
		this.renderScene = new RenderPass(this, this.activeCamera)
		this.fxaaPass = new ShaderPass(FXAAShader)
		this.fxaaPass.material.uniforms.resolution.value.x = 1 / (store.window.w * store.WebGL.renderer.getPixelRatio())
		this.fxaaPass.material.uniforms.resolution.value.y = 1 / (store.window.fullHeight * store.WebGL.renderer.getPixelRatio())

		this.bloomPass = new UnrealBloomPass(new Vector2(store.window.w * store.WebGL.renderer.getPixelRatio(), store.window.h * store.WebGL.renderer.getPixelRatio()), 1.5, 1, .9)
		this.bloomPass.enabled = true
	
		this.screenFxPass = new ShaderPass(new ShaderMaterial({
			vertexShader: screenFxVert,
			fragmentShader: screenFxFrag,
			uniforms: {
				tDiffuse: { value: null },
				uMaxDistort: { value: 0.251 },
				uBendAmount: { value: -0.272 }
			}
		}))

		this.composer.addPass(this.renderScene)
		// this.composer.addPass(this.screenFxPass)
		this.composer.addPass(this.bloomPass)
	}

	createFbo() {
		store.simFbo = new WebGLRenderTarget(
			store.window.w * store.WebGL.renderer.getPixelRatio(),
			store.window.h * store.WebGL.renderer.getPixelRatio()
		)
		E.emit('fboCreated')
	}

	buildDebugEnvironment() {
		this.add(new AmbientLight(0xf0f0f0))
		this.light = new SpotLight(0xffffff, 1.5)
		this.light.position.set(0, 1500, 200)
		this.light.angle = Math.PI * 0.2
		this.light.castShadow = true
		this.add(this.light)

		this.grid = new GridHelper(200, 50)
	}

	addEvents() {
		E.on(GlobalEvents.RESIZE, this.onResize)
		store.RAFCollection.add(this.onRaf, 1)
	}

	onRaf = () => {
		this.controls.enabled && this.controls.update()

		if (this.controls.enabled) {
			store.WebGL.renderer.render(this, this.devCamera)
			this.activeCamera = this.devCamera
		} else {
			store.WebGL.renderer.render(this, this.camera)
			this.activeCamera = this.orthoCamera
		}

		store.Gui && store.Gui.refresh(false)

		this.composer.render()
	}

	onResize = () => {
		this.camera.aspect = store.window.w / store.window.h
		this.camera.updateProjectionMatrix()
		store.envFbo.setSize(store.window.w * store.WebGL.renderer.getPixelRatio(), store.window.h * store.WebGL.renderer.getPixelRatio())
		this.composer.setSize(store.window.w, store.window.h)
	}

	load() {
		this.assets = {
			textures: {},
			models: {}
		}

		// store.AssetLoader.loadTexture('/textures/background.jpeg').then(texture => {
		// 	this.backgroundTexture = texture
		// })
	}
}