
THREE = require 'three'

COMPASS = {
	north: [1, 1]
	south: [-1, -1]
	east: [-1, 1]
	west: [1, -1]
}

class IsometricCamera
	directions: [
		'north'
		'east'
		'south'
		'west'
	]

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
		@camera._target = new THREE.Vector3 0, 0, 0
		@direction = 'north'

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

	_lookCardinal: (direction) ->
		# XXX There's probably a smarter way to acheive this

		origin = @camera.position.clone().sub @camera._target

		x = COMPASS[direction][0]
		y = COMPASS[direction][1]

		origin.set(
			x * Math.abs(origin.x),
			y * Math.abs(origin.y),
			origin.z,
		)

		origin.add @camera._target

		@camera.position.set(
			origin.x,
			origin.y,
			origin.z,
		)
		@camera.lookAt @camera._target
		@direction = direction

	lookNorth: ->
		# 125, 125, 125
		@_lookCardinal 'north'

	lookSouth: ->
		# -125, -125, 125
		@_lookCardinal 'south'

	lookEast: ->
		# 125, -125, 125
		@_lookCardinal 'east'

	lookWest: ->
		# -125, 125, 125
		@_lookCardinal 'west'

	rotate: (clockwise) ->
		index = @directions.indexOf @direction

		if clockwise
			index++
			index = 0 if index > 3
		else
			index--
			index = 3 if index < 0

		@_lookCardinal @directions[index]

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
	