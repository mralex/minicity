
THREE = require 'three'

class Renderer
	constructor: ->
		window.THREE = THREE

		@scene = new THREE.Scene
		@camera = new THREE.PerspectiveCamera 90, window.innerWidth / window.innerHeight, 0.1, 1000

		@camera.position.set(0, 0, 100)
		# @camera.rotation.order = 'YXZ'
		# @camera.rotation.y = - Math.PI / 4
		# @camera.rotation.x = Math.atan(-1 / Math.sqrt(2))
		@camera.rotation.set(0, 0, 0)

		@renderer = new THREE.WebGLRenderer {
		    alpha: true
		}

		@renderer.setSize window.innerWidth, window.innerHeight
		@renderer.setClearColor 0x111111

		@canvas = @renderer.domElement

		console.log 'adding lights'
		@light = new THREE.PointLight(0xffffff, 1.1, 0)
		@light.position.set(0.0, 0, 300)
		@scene.add @light

		window.addEventListener 'resize', @handleWindowResize

	getScene: ->
		@scene

	handleWindowResize: (e) =>
		@camera.aspect = window.innerWidth / window.innerHeight
		@camera.updateProjectionMatrix()
		@renderer.setSize window.innerWidth, window.innerHeight

	update: ->

	render: ->
		@renderer.render @scene, @camera

module.exports = Renderer
