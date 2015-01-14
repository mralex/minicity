#
# Tile baseclass
#

class Tile
	_type: ''
	width: 0
	height: 0
	x: 0
	y: 0
	population: 0

	constructor: (x, y) ->
		@x = x
		@y = y
		@neighbors = {}

	update: ->


module.exports = Tile
