
THREE = require 'three'
IsometricCamera = require './isometric_camera.coffee'

class Renderer
	constructor: ->
		window.THREE = THREE
		rad = 0.0174532925

		@scene = new THREE.Scene

		# @camera.position.set -300, 0, 400
		# @camera.rotation.order = 'YXZ'
		# @camera.rotation.y = - Math.PI / 4
		# @camera.rotation.x = Math.atan(-1 / Math.sqrt(2))
		# @camera.rotation.set(
		# 	45 * rad,
		# 	-45 * rad,
		# 	-30 * rad
		# )

		@renderer = new THREE.WebGLRenderer {
		    alpha: true
		}

		@renderer.setSize window.innerWidth, window.innerHeight
		@renderer.setClearColor 0xffffff

		@canvas = @renderer.domElement

		@isometricCamera = new IsometricCamera @canvas
		@camera = @isometricCamera.camera

		console.log 'adding lights'
		@light = new THREE.PointLight(0xffffff, 1.1, 0)
		# @light.position.set(0.0, 0, 600)
		@light.position.set(0.0, 0, 500)
		@scene.add @light

		window.addEventListener 'resize', @handleWindowResize

	getScene: ->
		@scene

	handleWindowResize: (e) =>
		@isometricCamera.update()

		@renderer.setSize window.innerWidth, window.innerHeight

	update: ->

	render: ->
		@renderer.render @scene, @camera

module.exports = Renderer
