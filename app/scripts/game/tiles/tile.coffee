#
# Tile baseclass
#

THREE = require 'three'

class Tile
	_type: ''
	width: 0
	height: 0
	x: 0
	y: 0
	population: 0

	constructor: (x, y) ->
		@position = new THREE.Vector2(x, y)
		@x = x
		@y = y
		@neighbors = {}

	type: ->
		@_type

	update: ->


module.exports = Tile
