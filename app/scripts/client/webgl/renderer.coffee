
THREE = require 'three'

class Renderer
	constructor: (width=1280, height=720) ->
		@width = width
		@height = height

		window.THREE = THREE

		@scene = new THREE.Scene
		@camera = new THREE.PerspectiveCamera 75, @width/@height, 0.1, 1000

		@camera.position.set(0, 0, 100)
		# @camera.rotation.order = 'YXZ'
		# @camera.rotation.y = - Math.PI / 4
		# @camera.rotation.x = Math.atan(-1 / Math.sqrt(2))
		@camera.rotation.set(0, 0, 0)

		@renderer = new THREE.WebGLRenderer {
		    alpha: true
		}

		@renderer.setSize @width, @height
		@renderer.setClearColor 0xffffff

		@canvas = @renderer.domElement

		console.log 'adding lights'
		@light = new THREE.PointLight(0xffffff, 1.1, 0)
		@light.position.set(0.0, 0, 200)
		@scene.add @light

	getScene: ->
		@scene

	update: ->

	render: ->
		@renderer.render @scene, @camera

module.exports = Renderer
