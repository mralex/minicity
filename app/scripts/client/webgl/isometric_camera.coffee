
THREE = require 'three'

class IsometricCamera
	constructor: (domElement) ->
		@domElement = domElement

		@_aspect = window.innerWidth / window.innerHeight
		@viewSize = 200

		@maxZoom = 60
		@minZoom = 400
		@camera = new THREE.OrthographicCamera -@viewSize * @_aspect, @viewSize * @_aspect, @viewSize, -@viewSize, -10000, 10000

		@camera.position.set 125, 125, 125
		@camera.up = new THREE.Vector3 0, 0, 1
		@camera.lookAt new THREE.Vector3 0, 0, 0

		@domElement.addEventListener 'mousewheel', @handleMouseWheel

	setCameraSize: (size) ->
		if size < @maxZoom
			size = @maxZoom
		else if size > @minZoom
			size = @minZoom

		@viewSize = size

		@_updateCameraSize()

	_updateCameraSize: ->
		@camera.left = -@viewSize * @_aspect
		@camera.right = @viewSize * @_aspect
		@camera.top = @viewSize
		@camera.bottom = -@viewSize
		@camera.updateProjectionMatrix()

	update: ->
		@_aspect = window.innerWidth / window.innerHeight
		@_updateCameraSize()

	handleMouseWheel: (e) =>
		delta = 0

		if e.wheelDelta
			# WebKit / Opera / Explorer 9
			delta = e.wheelDelta / 40;
		else if e.detail
			# Firefox
			delta = - e.detail / 3;

		@setCameraSize(@viewSize - (delta * 10))

module.exports = IsometricCamera
	