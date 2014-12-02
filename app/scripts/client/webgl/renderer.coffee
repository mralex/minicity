
THREE = require 'three'
IsometricCamera = require './isometric_camera.coffee'

class Renderer
	constructor: ->
		window.THREE = THREE
		rad = 0.0174532925

		@scene = new THREE.Scene

		@renderer = new THREE.WebGLRenderer {
		    alpha: true
		}

		@renderer.setSize window.innerWidth, window.innerHeight
		@renderer.setClearColor 0xffffff

		@canvas = @renderer.domElement

		@isometricCamera = new IsometricCamera @canvas
		@camera = @isometricCamera.camera

		console.log 'adding lights'
		@light = new THREE.DirectionalLight(0xffffff, 1.2)
		@light.position.set(1, 2, 5).normalize()
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
