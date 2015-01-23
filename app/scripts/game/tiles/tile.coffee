#
# Tile baseclass
#

THREE = require 'three'
_ = require 'underscore'

class Tile
	_type: ''
	width: 0
	height: 0
	x: 0
	y: 0
	population: 0
	roadScore: -1

	constructor: (x, y) ->
		@position = new THREE.Vector2(x, y)
		@x = x
		@y = y
		@neighbors = {}

	type: ->
		@_type

	isNextToRoad: ->
		if _.isEmpty @neighbors
			return

		(tile for direction, tile of @neighbors when tile.type() is 'road')

	update: ->


module.exports = Tile
